<p align="center">
  <img width="180" src="./attachments/Images/cat.ico" alt="lazy.ico">
  <h1 align="center">LazyWorld</h1>
  <p align="center">AHK is a versatile tool that can be used for a wide range of automation tasks :)</p>
</p>

## 🖊️ Fonts

### Download links
- [JetBrainsMono](https://github.com/Lazy-World/warframe-ahk/raw/main/attachments/Fonts/JetBrainsMono-Medium.ttf): "**JetBrains Mono Medium**" in *.ahk file
- [Montserrat](https://github.com/Lazy-World/warframe-ahk/raw/main/attachments/Fonts/Montserrat-Medium.otf): "**Montserrat Medium**" in *.ahk file

### Font setup

1. Download and install any font you want
1. Open [**.ttf** or **.otf**] and copy **"Font name:"**
1. Open script file and edit **["title", "main", "info"]**

### ⚙️ Step by Step instruction

- [Download font](#download-links) then find "Font name" field and copy font's name

  ![get_fontname preview](./attachments/Images/get_fontname.png)

- Open script and select Font names for each category. In my case I use **Montserrat Medium** for each category
  ```ahk
  ui_theme.insert("title", "Montserrat Medium")
  ui_theme.insert("main",  "Montserrat Medium")
  ui_theme.insert("info",  "Montserrat Medium")
  ```
- Run or reload script file.

### Preview

- **JetBrainsMono** Font preview of **UI** in **vs_propa_raplak.ahk**

  ![JetBrainsMono preview](./attachments/Images/JetBrainsMono-Preview.png)

- **Montserrat** Font preview of **UI** in **vs_propa_raplak.ahk**

  ![Montserrat preview](./attachments/Images/Montserrat-Medium-Preview.png)

---

## 📦 Libraries