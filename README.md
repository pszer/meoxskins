# MeoxSkins skin editor for Minecraft.
## Usage
### Linux:
Ensure the Love2D package is installed. This can be done with

- Debian/Ubuntu: sudo apt install love"
- Fedora:        sudo dnf install love"
- Arch Linux:    sudo pacman -S love"
- Or visit https://love2d.org/ for more options."

MeoxSkins be launched via the console, using 
>./meoxskin

or

>love meoxskins.love "skin.png" "slim"/"wide"

### Windows:
Launch the executable file
>MeoxSkins.exe

that comes with the release.

![Viewport](https://github.com/pszer/meoxskins/blob/master/screenshot.png)

Use <ins>File > Open</ins> to open an existing skin, or start painting from scratch.

## Viewport actions

**Left click** on the model to paint it with the active colour. Pressing **X** will fully erase.

You will need to hide and unhide limbs to paint where you need, this can be done by clicking on the **Visible Parts** window, or by using the default **1/2/3/4/5/6** keybinds to hide the *head, left arm, right arm, left arm, right leg and torso* parts of the model. **Tab** can also be used to toggle all the overlay parts of the playermodel.

**Right click** or **Middle click** on the viewport outside the playermodel to rotate your view. The **Scroll wheel** will zoom in and out.

**Middle click** on a window or **Left Click** on its titlebar in order to move it using the mouse.

**Ctrl+Z**, **Ctrl+Y** will undo/redo recent actions.

## Colour Picker

The active colour can be seen in the top right square of the **Colour picker** and a new colour can be chosen by clicking a spot on the large *Saturation and Lightness* region on the left and adjusting the *Hue slider*.

The second slider on the far right is the **Alpha slider** and it determines the transparency of the colour, this is useful for blending colours into the skin rather than painting them directly. Alpha blending only happens when painting on an already opaque pixels because *Minecraft does not support alpha blending for player skins*, it turns the pixels fully opaque if alpha is non-zero, and so to mirror this behaviour painting with a transparent colour onto a transparent pixel will paint with full opacity.

Already existing colours on the skin can be picked by pressing **O** whilst hovering it underneath the cursor, this will not change the current alpha you are working with.

![Viewport](https://github.com/pszer/meoxskins/blob/master/picker.png)

## Skin types

*Wide* skins(Steve by default) have arms that are *4 pixels* wide, on *slim* skins (Alex by default) they are *3 pixels wide*. Please select your desired mode using **Skin > Wide/Slim mode**. This is non-destructive and can always be reversed.

## Layers

You can utilize layers to organise different parts of your skin, such as base flesh, clothes, hair, and so on. In the **Edit** section of the toolbar you will find options to create, delete, move** and merge layers.

Once layers are created, they will show up in the **Layer viewer** on the right side of the screen. The active layer will be highlighted and it can be switched by clicking on another.

Layers can be **hidden** by pressing their respective eye icon in the **Layer viewer** seen on the right of the layer name. Beside it is also an icon to enable **Alpha-channel locking** for that layer which will prevent painting onto transparent pixels; it is recommended to alpha-lock layers when they have a shape you're happy with as a precaution to accidentally painting on the wrong layers, alpha-lock can be fully ignored when painting by holding **A** whilst painting so it is hassle free.

When saving your skin, the *File > Save* option will merge all layers into a .png image that Minecraft can use. If you wish to save your layers use **File > Save as project** which will export them all side-by-side in one image file which can be reopened by MeoxSkins.

![ExampleSkinProject](https://github.com/pszer/meoxskins/blob/master/testskin.png)

## Filters

There are four filters/colour adjustment tools which can be accessed in the **Filters** section of the toolbar. Any filter will be applied solely on the active layer, and recently used filters can be repeatedly applied in the <ins>Recently used</ins> submenu.

### Contrast/Brightness

Higher and lower contrast will scale the distance of colours from the midpoint *RGB(.5,.5,.5)* by 2using the *Con* slider, a uniform change to luminance can then be applied with the *Lum* slider.

![Contrast Brightness](https://github.com/pszer/meoxskins/blob/master/contrast.png)

### Adjust HSL

Colour hue and saturation can be changed using the *Hue* and *Sat* sliders, and luminance adjusted with the *Lum* slider. The default behaviour of the *Lum* slider is a scalar multiplication to luminance, but a more perceptually soft and gamma-like adjustment can be done by enabling the *Gamma* option on the side.

![Contrast Brightness](https://github.com/pszer/meoxskins/blob/master/adjustHSL.png)

### Curves

Curves is a powerful colour and contrast adjustment tool in which the lightness and/or RGB channels of colours are shifted according to a user-defined curve. The X-axis represents the value of a pixel's colour from 0.0 to 1.0 and the curve above shows where it will land on the Y-axis which also goes from 0.0 to 1.0. Four curves can be defined for the value/lightness of colours and their red, green and blue channels - if you wish to only adjust lightness you only need to use the value curve. By default all curves are a straight line from 0.0 to 1.0 which create no change.

A curve can be created by *clicking on the graph* to create points through which the curve will then smoothly go through. These points can be clicked and dragged to adjust position as needed, and if a point needs to be deleted: simply move it out of range either to the far left or right, it will delete itself once it crosses over another point. The channel to be adjusted can be selected with the checkboxes above the graph, and its curve reset with the *Reset* button.

On the graph there is a histogram showing how many pixels fall into a certain colour range, with the histogram corresponding to whatever value/RGB channel is currently active.

![Curves](https://github.com/pszer/meoxskins/blob/master/curves.png)

### Invert (HSL)

This filter produces inverted colours which are somewhat perceptually correct by rotating their hues by 180° and inverting their luminance *(1.0 - Lum)*.

## Additional Controls

- **F** - Fills the face underneath the cursor completely with the current colour.

- **O** - Picks the colour underneath the cursor.

- **M** - Toggles mirror editing, under which all painting to the limbs is mirrored on the opposing one. It can also be toggled on the *Visible Parts* window.

- **G** - Toggles the visibility of the grid overlay. Also available in *Edit > Toggle Grid*

- **A** - Whilst held, painting ignores the alpha lock of the active layer.

All keybinds can be changed by going to the **File** section on the toolbar and pressing **Key settings**. Each action can have two keys bound to it and they will be shown in the *key settings* window on two buttons, if you left click a button it will change the keybinding to whatever next input you press.

## Posing

The pose of the model can be adjusted by going to the **Skin** section in the toolbar and pressing **Pose**.

In this window the *pitch, yaw and roll* rotation of each limb can be changed with the sliders. This can be useful for painting regions that obfuscate themselves in the default pose, or for screenshots!

![Pose window](https://github.com/pszer/meoxskins/blob/master/pose.png)

### Additional notes

The language of the program can be changed by going to **Help** on the toolbar and pressing **Set Language**, the currently supported languages are
- English
- Polish / Polski
- Japanese / 日本語

An autosave is made every 10 seconds and will be recovered in case the program crashes.

# License

See *LICENSE.MD* (MIT License)

