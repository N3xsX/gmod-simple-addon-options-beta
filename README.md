## Overview
The Simple Addon Options File is designed to streamline the process of implementing customizable settings in Garry's Mod addons. By using a simple and easy to read configuration file, developers can easily define various options for players to adjust according to their preferences.

## Features
* Easy configuration: Define options using a straightforward syntax in a single file.
* Support for various types of options: Includes support for checkboxes, sliders, text entries, combo boxes, and more (including custom types).
* Customization options: Specify default values, minimum and maximum limits, and additional flags for each option.
* Seamless integration: Integrate the options file into your addon with minimal effort.
* Semi-Automatic conVar Creation: Don't worry about using CreateConVar or CreateClientConVar afterward. This addon will automatically create them, so you can just copy them
* Grouping and Organization: Allows options to be grouped or categorized for better organization and navigation within the options file and in menu.
* Validation and Error Handling: Addon contains its own error system that will tell you what is wrong
## Getting Started
To get started with the Simple Addon Options File, follow these steps:

* Download the Template: Download the template file provided in this repository.

* Define Options: Open the template file in a text editor and define your addon's options using the provided syntax.

* Customize Options: Customize each option according to your addon's requirements. Specify the type, default value, minimum and maximum limits, and any additional flags.

* Integrate Options: Integrate the options into your addon's code to read and apply the settings as needed.

* Test: Test your addon to ensure that the options are correctly implemented and functioning as expected.

## Configuration Syntax
The Simple Addon Options File uses a simple syntax to define options. Each option is defined using a key-value pair format with various properties specified.

Example:
```
option1 = {
    name = "Enable Feature",
    description = "Toggle to enable/disable the feature",
    type = "checkbox",
    conVar = "addon_enable_feature",
    default = 1,
    flags = {}
},
```

## Support and Feedback
If you encounter any issues or have suggestions for improving the Simple Addon Options, please don't hesitate to reach out. Your feedback is valuable and helps me enhance the addon for the community.

## License
The Simple Addon Options File is released under the MIT License. See the LICENSE file for more details.
