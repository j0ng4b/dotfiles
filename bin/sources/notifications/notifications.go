package main

import (
    "bufio"
    "encoding/json"
    "fmt"
    "image"
    "image/color"
    "image/png"
    "log"
    "os"
    "path/filepath"

    "github.com/fsnotify/fsnotify"
    "github.com/godbus/dbus/v5"
)

const (
    dbusNotificationsInterface = "org.freedesktop.Notifications"
    dbusNotificationsMethod    = "Notify"
)

func main() {
    // Create a channel for notifications from the file watcher
    notifications := make(chan map[string]interface{}, 10)

    // Create a new file watcher
    watcher, err := fsnotify.NewWatcher()
    if err != nil {
        log.Fatal(err)
    }
    defer watcher.Close()

    // Add the file where notifications are stored to watcher
    path := os.Getenv("XDG_CACHE_HOME")
    if path == "" {
        path = filepath.Join(os.Getenv("HOME"), ".cache")
    }

    err = watcher.Add(filepath.Join(path, "scripter/notification/list"))
    if err != nil {
        log.Fatal(err)
    }

    // Watch for file events in a separate goroutine
    go func ()  {
        for {
            select {
            case event, ok := <-watcher.Events:
                if !ok {
                    return
                }

                if event.Has(fsnotify.Write) {
                    // Open the notifications file
                    file, err := os.Open(event.Name)
                    if err != nil {
                        log.Println("error:", err)
                        continue
                    }

                    // Read the last line of the file (the latest notification)
                    var lastline string
                    scanner := bufio.NewScanner(file)
                    for scanner.Scan() {
                        lastline = scanner.Text()
                    }

                    if len(lastline) == 0 {
                        file.Close()
                        continue
                    }

                    // Parse the notification data
                    var data map[string]interface{}
                    err = json.Unmarshal([]byte(lastline), &data)
                    if err != nil {
                        log.Printf("Failed to parse notification data: %v", err)
                        file.Close()
                        continue
                    }

                    // Send the notification data to the channel
                    notifications <- data
                    file.Close()
                }

            case err, ok := <-watcher.Errors:
                if !ok {
                    return
                }
                log.Println("error:", err)
            }
        }
    }()

    // Connect to the session bus
    conn, err := dbus.SessionBus()
    if err != nil {
        log.Fatal("Failed to connect to session bus:", err)
    }
    defer conn.Close()

    // Add match rule for notifications
    err = conn.BusObject().Call(
        "org.freedesktop.DBus.AddMatch",
        0,
        fmt.Sprintf(
            "type='method_call',interface='%s',member='%s',eavesdrop='true'",
            dbusNotificationsInterface,
            dbusNotificationsMethod,
        ),
    ).Err
    if err != nil {
        log.Fatal("Failed to add match rule:", err)
    }


    // Create a channel for messages
    c := make(chan *dbus.Message, 10)
    conn.Eavesdrop(c)

    for msg := range c {
        // Only process method calls
        if msg.Type != dbus.TypeMethodCall {
            continue
        }

        // Only process notifications of member Notify
        if msg.Headers[dbus.FieldMember].String() != dbusNotificationsMethod {
            handleNotification(msg, notifications)
        }
    }
}

func handleNotification(msg *dbus.Message, notifications <-chan map[string]interface{}) {
    if len(msg.Body) < 8 {
        return
    }

    // If there are hints with icon data
    if hints, ok := msg.Body[6].(map[string]dbus.Variant); ok {
        for _, name := range []string{ "icon_data", "image_data", "image-data" } {
            if data, exists := hints[name]; exists {
                notification := <-notifications

                iconPath := filepath.Join(
                    os.Getenv("XDG_CACHE_HOME"),
                    "scripter/notification/icons",
                    notification["id"].(string),
                )

                saveIcon(data.Value().([]interface {}), iconPath)
                break
            }
        }
    }
}

func saveIcon(data []interface {}, iconPath string) {
    // Extract image data and metadata
    width := data[0].(int32)
    height := data[1].(int32)
    rowstride := data[2].(int32)
    hasAlpha := data[3].(bool)
    bitsPerSample := data[4].(int32)
    nChannels := data[5].(int32)
    rawData := data[6].([]uint8)

    // Check if the icon format is supported
    if bitsPerSample != 8 {
        log.Printf("Unsupported icon format: %d bits per sample", bitsPerSample)
        return
    }

    // Load image data into an image object
    img := image.NewRGBA(image.Rect(0, 0, int(width), int(height)))

    var x, y int32
    for y = 0; y < height; y++ {
        for x = 0; x < width; x++ {
            offset := y*rowstride + x*nChannels

            var r, g, b, a uint8
            if nChannels == 3 || nChannels == 4 {
                r = rawData[offset]
                g = rawData[offset+1]
                b = rawData[offset+2]

                if hasAlpha && nChannels == 4 {
                    a = rawData[offset+3]
                } else {
                    a = 255
                }
            }

            img.SetRGBA(int(x), int(y), color.RGBA{r, g, b, a})
        }
    }

    // Save image to a file
    file, err := os.Create(iconPath)
    if err != nil {
        log.Printf("Failed to create file: %v", err)
        return
    }
    defer file.Close()

    err = png.Encode(file, img)
    if err != nil {
        log.Printf("Failed to save image data: %v", err)
        return
    }
}

