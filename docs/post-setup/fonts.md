# Fonts

Install and configure fonts for editors, terminals, and Python visualization libraries.

## UDEV Gothic

**Download**: https://github.com/yuru7/udev-gothic/releases/latest  
**File**: `UDEVGothic_NF_v*.zip` (Nerd Fonts version)

**Installation**:
- **Windows**: `.ttf` files
- **macOS**: `.ttf` files
- **Linux**: `mkdir -p ~/.local/share/fonts/udev-gothic && cp *.ttf ~/.local/share/fonts/udev-gothic/ && fc-cache -fv`
- **WSL**: Install on Windows host (WSL installation doesn't work for host apps)

**Usage**: Configure in editor/terminal settings (font name: `UDEV Gothic 35NFLG`)

## Python Visualization Fonts

**Fonts**:
- **Noto Sans JP**: https://fonts.google.com/noto/specimen/Noto+Sans+JP (Japanese text)
- **Roboto**: https://fonts.google.com/specimen/Roboto (Latin characters)

**Installation**:
- **Windows/macOS/Linux**: Download from Google Fonts and install

### matplotlib

```python
plt.rcParams['font.family'] = 'Noto Sans JP'
plt.rcParams['font.sans-serif'] = ['Roboto', 'Noto Sans JP', 'DejaVu Sans']
```

### streamlit

```python
st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700&family=Roboto:wght@400;700&display=swap');

html, body, [class*="css"] {
    font-family: 'Roboto', 'Noto Sans JP', sans-serif;
}
</style>
""", unsafe_allow_html=True)
```

**Note**: Browser automatically selects Roboto for Latin characters and Noto Sans JP for Japanese characters in mixed text.

### altair

```python
# Default: Roboto for Latin characters
chart = alt.Chart(data).configure(
    font='Roboto'
).configure_axis(
    labelFont='Roboto',
    titleFont='Roboto'
)

# For Japanese text in data, specify font explicitly
chart = alt.Chart(data).mark_text(
    font='Noto Sans JP'
).encode(
    text='japanese_column:N'
)
```

**Note**: For mixed text, use `font='Noto Sans JP'` in `mark_text()` - the font will handle both Japanese and Latin characters, though Latin may fall back to Noto Sans JP's Latin glyphs.
