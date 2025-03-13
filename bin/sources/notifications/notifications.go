package main

import (
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
    // Create a new file watcher
    watcher, err := fsnotify.NewWatcher()
    if err != nil {
        log.Fatal(err)
    }
    defer watcher.Close()

    // Add the file where notifications are stored to watcher
    err = watcher.Add("")
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
                    log.Println("modified file:", event.Name)
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
    m := make(chan *dbus.Message, 10)
    conn.Eavesdrop(m)

	fmt.Println("\nListening for notifications... Press Ctrl+C to exit")

	for msg := range m {
		// Only process method calls
        if msg.Type != dbus.TypeMethodCall {
            continue
        }

        // Only process notifications of member Notify
        if msg.Headers[dbus.FieldMember].String() != dbusNotificationsMethod {
            handleNotification(msg)
        }
	}
}

func handleNotification(msg *dbus.Message) {
	if len(msg.Body) < 8 {
		return
	}

	details := make(map[string]interface{})

	// Safely extract values
	if len(msg.Body) > 6 {
		details["hints"] = msg.Body[6]
	}

	// If there are hints with icon data
	if hints, ok := details["hints"].(map[string]dbus.Variant); ok {
        for _, name := range []string{ "icon_data", "image_data", "image-data" } {
            if data, exists := hints[name]; exists {
                saveIcon(data.Value().([]interface {}))
                break
            }
        }
	}
}

func saveIcon(data []interface {}) {
    // Extract image data and metadata
    width := data[0].(int32)
	height := data[1].(int32)
	rowstride := data[2].(int32)
	hasAlpha := data[3].(bool)
	bitsPerSample := data[4].(int32)
	nChannels := data[5].(int32)
	rawData := data[6].([]uint8)

    // Check if the icon format is supported
    if bitsPerSample != 8 || nChannels != 4 {
        log.Printf("Unsupported icon format: %d bits per sample, %d channels", bitsPerSample, nChannels)
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
    file, err := os.Create(filepath.Join(os.TempDir(), "icon.png"))
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

    log.Printf("Saved icon to %s", file.Name())
}

// func getTimestamp() uint64 {
//     data, err := os.ReadFile("/proc/uptime")
//     if err != nil {
//         log.Fatal("Failed to read uptime:", err)
//     }

//     uptimeStr := strings.Split(string(data), " ")[0]
//     uptime, err := strconv.ParseFloat(uptimeStr, 64)
//     if err != nil {
//         log.Fatal("Failed to parse uptime:", err)
//     }

//     return uint64(uptime)
// }

