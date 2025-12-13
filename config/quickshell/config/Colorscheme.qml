pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  property var current: dark

  property alias dark: dark
  property alias light: light


  FileView {
    watchChanges: true
    path: Config.configPath + '/colorscheme.json'

    onFileChanged: this.reload()
    onAdapterUpdated: this.writeAdapter()
    onLoadFailed: err => {
      if (err == FileViewError.FileNotFound)
        this.writeAdapter()
    }


    JsonAdapter {
      property JsonObject colors: JsonObject {
        property JsonObject dark: JsonObject {
          id: dark

          property color background: '#111318'
          property color error: '#ffb4ab'
          property color error_container: '#93000a'
          property color inverse_on_surface: '#2f3036'
          property color inverse_primary: '#435e91'
          property color inverse_surface: '#e2e2e9'
          property color on_background: '#e2e2e9'
          property color on_error: '#690005'
          property color on_error_container: '#ffdad6'
          property color on_primary: '#0f2f60'
          property color on_primary_container: '#d7e2ff'
          property color on_primary_fixed: '#001a40'
          property color on_primary_fixed_variant: '#2a4678'
          property color on_secondary: '#283041'
          property color on_secondary_container: '#dae2f9'
          property color on_secondary_fixed: '#131c2c'
          property color on_secondary_fixed_variant: '#3f4759'
          property color on_surface: '#e2e2e9'
          property color on_surface_variant: '#c4c6d0'
          property color on_tertiary: '#402844'
          property color on_tertiary_container: '#fbd7fc'
          property color on_tertiary_fixed: '#29132d'
          property color on_tertiary_fixed_variant: '#573e5b'
          property color outline: '#8e9099'
          property color outline_variant: '#44474f'
          property color primary: '#acc7ff'
          property color primary_container: '#2a4678'
          property color primary_fixed: '#d7e2ff'
          property color primary_fixed_dim: '#acc7ff'
          property color scrim: '#000000'
          property color secondary: '#bec6dc'
          property color secondary_container: '#3f4759'
          property color secondary_fixed: '#dae2f9'
          property color secondary_fixed_dim: '#bec6dc'
          property color shadow: '#000000'
          property color surface: '#111318'
          property color surface_bright: '#37393e'
          property color surface_container: '#1e2025'
          property color surface_container_high: '#282a2f'
          property color surface_container_highest: '#33353a'
          property color surface_container_low: '#1a1b20'
          property color surface_container_lowest: '#0c0e13'
          property color surface_dim: '#111318'
          property color surface_tint: '#acc7ff'
          property color surface_variant: '#44474f'
          property color tertiary: '#debcdf'
          property color tertiary_container: '#573e5b'
          property color tertiary_fixed: '#fbd7fc'
          property color tertiary_fixed_dim: '#debcdf'
        }

        property JsonObject light: JsonObject {
          id: light

          property color background: '#f9f9ff'
          property color error: '#ba1a1a'
          property color error_container: '#ffdad6'
          property color inverse_on_surface: '#f0f0f7'
          property color inverse_primary: '#acc7ff'
          property color inverse_surface: '#2f3036'
          property color on_background: '#1a1b20'
          property color on_error: '#ffffff'
          property color on_error_container: '#410002'
          property color on_primary: '#ffffff'
          property color on_primary_container: '#001a40'
          property color on_primary_fixed: '#001a40'
          property color on_primary_fixed_variant: '#2a4678'
          property color on_secondary: '#ffffff'
          property color on_secondary_container: '#131c2c'
          property color on_secondary_fixed: '#131c2c'
          property color on_secondary_fixed_variant: '#3f4759'
          property color on_surface: '#1a1b20'
          property color on_surface_variant: '#44474f'
          property color on_tertiary: '#ffffff'
          property color on_tertiary_container: '#29132d'
          property color on_tertiary_fixed: '#29132d'
          property color on_tertiary_fixed_variant: '#573e5b'
          property color outline: '#74777f'
          property color outline_variant: '#c4c6d0'
          property color primary: '#435e91'
          property color primary_container: '#d7e2ff'
          property color primary_fixed: '#d7e2ff'
          property color primary_fixed_dim: '#acc7ff'
          property color scrim: '#000000'
          property color secondary: '#565e71'
          property color secondary_container: '#dae2f9'
          property color secondary_fixed: '#dae2f9'
          property color secondary_fixed_dim: '#bec6dc'
          property color shadow: '#000000'
          property color source_color: '#7b92c2'
          property color surface: '#f9f9ff'
          property color surface_bright: '#f9f9ff'
          property color surface_container: '#ededf4'
          property color surface_container_high: '#e8e7ee'
          property color surface_container_highest: '#e2e2e9'
          property color surface_container_low: '#f3f3fa'
          property color surface_container_lowest: '#ffffff'
          property color surface_dim: '#d9d9e0'
          property color surface_tint: '#435e91'
          property color surface_variant: '#e1e2ec'
          property color tertiary: '#715574'
          property color tertiary_container: '#fbd7fc'
          property color tertiary_fixed: '#fbd7fc'
          property color tertiary_fixed_dim: '#debcdf'
        }
      }
    }
  }
}

