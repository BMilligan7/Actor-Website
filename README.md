# Actor Portfolio Website

A simple, modern, and professional website for actors to showcase their work.

## Features

- **Bio Section**: Tell your story and background
- **Demo Reel**: Embed your video reel (YouTube, Vimeo, or direct video)
- **Headshots Gallery**: Display your professional headshots
- **Resume**: Downloadable PDF resume
- **Contact Information**: Email, phone, agent details, and social media links
- **Responsive Design**: Works beautifully on desktop, tablet, and mobile devices
- **Smooth Animations**: Professional fade-in effects and smooth scrolling

## Setup Instructions

1. **Personalize the Content**:
   - Open `index.html` and replace "Your Name" with your actual name
   - Update the bio section with your personal information
   - Add your contact information (email, phone, agent details)
   - Update social media links

2. **Add Your Demo Reel**:
   - Find your video on YouTube or Vimeo
   - Get the embed code or video ID
   - Replace the placeholder in the reel section with your video embed code
   - For YouTube: Use format `https://www.youtube.com/embed/YOUR_VIDEO_ID`
   - For Vimeo: Use format `https://player.vimeo.com/video/YOUR_VIDEO_ID`

3. **Add Your Headshots**:
   - Create an `images` folder in the project directory
   - Add your headshot images (JPG or PNG format recommended)
   - Update the image paths in `index.html` (e.g., `images/headshot1.jpg`)

4. **Add Your Resume**:
   - Create a `resume` folder in the project directory
   - Save your resume as a PDF file (e.g., `your-resume.pdf`)
   - Update the resume link in `index.html` to match your filename

5. **Customize Colors (Optional)**:
   - Open `styles.css`
   - Modify the color variables at the top of the file:
     - `--primary-color`: Main dark color
     - `--accent-color`: Gold/yellow accent color
     - Adjust other colors as needed

## File Structure

```
/
├── index.html          # Main HTML file
├── styles.css          # All styling
├── script.js           # JavaScript for interactivity
├── images/             # Your headshot images (create this folder)
│   ├── headshot1.jpg
│   ├── headshot2.jpg
│   └── headshot3.jpg
└── resume/             # Your resume PDF (create this folder)
    └── your-resume.pdf
```

## Viewing Your Website

1. **Local Viewing**: Simply open `index.html` in your web browser
2. **Online Hosting**: Upload all files to a web hosting service like:
   - GitHub Pages (free)
   - Netlify (free)
   - Vercel (free)
   - Your own web hosting

## Customization Tips

- **Fonts**: To change fonts, update the `font-family` in `styles.css`
- **Layout**: Adjust spacing and sizing in the CSS file
- **Sections**: Add or remove sections by copying the section structure in `index.html`
- **Colors**: Modify the CSS variables for a completely different look

## Browser Support

This website works on all modern browsers:
- Chrome
- Firefox
- Safari
- Edge

## Need Help?

If you need to make changes or have questions, the code is well-commented and easy to modify. Each section in the HTML is clearly labeled, making it simple to update your content.

