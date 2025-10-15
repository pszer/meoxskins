# MeoxSkins – Skin Editor for Minecraft

## Usage

### Linux
Ensure the **Love2D** package is installed. You can do this via your package manager:

```bash
# Debian / Ubuntu
sudo apt install love

# Fedora
sudo dnf install love

# Arch Linux
sudo pacman -S love
```

Alternatively, visit [love2d.org](https://love2d.org/) for installation options.

Launch **MeoxSkins** from the console with:
```bash
./meoxskin
```
or
```bash
love meoxskins.love "skin.png" "slim"/"wide"
```

### Windows
Run the included executable:
```
MeoxSkins.exe
```

![Viewport](https://github.com/pszer/meoxskins/blob/master/screenshot.png)

Use **File → Open** to load an existing skin, or start painting from scratch.

---

## Viewport Actions

- **Left-click** on the model to paint with the active color.  
  Press **X** to fully erase.  
- Toggle limb visibility by clicking in the **Visible Parts** window, or use **1–6** to hide or unhide the *head, left arm, right arm, left leg, right leg,* and *torso.*  
  Press **Tab** to toggle overlay parts.  
- **Right-click** or **Middle-click** outside the model to rotate the view.  
  Use the **Scroll wheel** to zoom.  
- **Middle-click** on a window or **Left-click** its title bar to drag it.  
- **Ctrl + Z** / **Ctrl + Y** to undo/redo actions.

---

## Colour Picker

The active color appears in the top-right square of the **Colour Picker**.  
Choose a new color by clicking in the *Saturation/Lightness* area and adjusting the *Hue* slider.

The **Alpha slider** controls transparency — useful for blending colors.  
*Alpha blending* only applies to already opaque pixels, since Minecraft skins do not support partial transparency. Painting with a transparent color on a transparent pixel will result in full opacity.

Pick an existing color by pressing **O** while hovering over it. This does not affect the current alpha value.

![Colour Picker](https://github.com/pszer/meoxskins/blob/master/picker.png)

---

## Skin Types

- **Wide skins** (Steve) have *4-pixel-wide* arms.  
- **Slim skins** (Alex) have *3-pixel-wide* arms.  

Switch between them via **Skin → Wide/Slim mode**. This change is non-destructive and reversible.

---

## Layers

Organize parts of your skin (base, clothes, hair, etc.) using layers.  
Under **Edit**, you’ll find options to **create**, **delete**, **move**, and **merge** layers.

Layers appear in the **Layer Viewer** on the right.  
Click a layer to make it active.

- Toggle visibility with the **eye icon**.  
- Enable **Alpha-channel lock** to prevent painting over transparent pixels.  
  (Hold **A** to temporarily ignore alpha lock while painting.)

When saving:
- **File → Save** merges layers into a standard `.png` for Minecraft.  
- **File → Save as Project** exports all layers side-by-side in a single image, reopenable by MeoxSkins.

![Example Skin Project](https://github.com/pszer/meoxskins/blob/master/testskin.png)

---

## Filters

Access four color-adjustment tools under **Filters** in the toolbar.  
Filters apply only to the active layer. Recently used filters appear under **Recently Used**.

### Contrast / Brightness
Adjust contrast with the *Con* slider and brightness with *Lum*.  
Contrast scales color distance from midpoint `RGB(0.5, 0.5, 0.5)`.

![Contrast Brightness](https://github.com/pszer/meoxskins/blob/master/contrast.png)

### Adjust HSL
Modify *Hue*, *Saturation*, and *Luminance*.  
The *Gamma* option makes luminance changes more perceptually soft.

![Adjust HSL](https://github.com/pszer/meoxskins/blob/master/adjustHSL.png)

### Curves
A powerful tool for fine-tuning contrast and color.  
Adjust lightness or RGB channels using editable curves, where:
- X-axis = input value (0.0–1.0)  
- Y-axis = output value (0.0–1.0)

Create curve points by clicking the graph; drag to adjust.  
Delete points by moving them off the edge.  
Select channels via checkboxes and reset with **Reset**.  
A histogram displays pixel distribution for the active channel.

![Curves](https://github.com/pszer/meoxskins/blob/master/curves.png)

### Invert (HSL)
Inverts colors perceptually by rotating hue 180° and setting luminance to `1.0 - Lum`.

---

## Additional Controls

- **F** – Fill the face under the cursor with the current color.  
- **O** – Pick color under the cursor.  
- **M** – Toggle mirrored editing (also available under *Visible Parts*).  
- **G** – Toggle grid overlay (*Edit → Toggle Grid*).  
- **A** – Hold to ignore alpha lock on the active layer.  

Change keybinds via **File → Key Settings**.  
Each action supports two bindings. Click a key button and press the new key to assign it.

---

## Posing

Adjust the model’s pose via **Skin → Pose**.  
Modify *Pitch*, *Yaw*, and *Roll* for each limb using sliders — useful for painting hard-to-reach areas or taking screenshots.

![Pose Window](https://github.com/pszer/meoxskins/blob/master/pose.png)

---

## Additional Notes

Change the program language via **Help → Set Language**.  
Supported languages:
- English  
- Polish / Polski  
- Japanese / 日本語  

Autosaves occur every 10 seconds and are recovered after a crash.

---

## License

See **LICENSE.md** (MIT License)
