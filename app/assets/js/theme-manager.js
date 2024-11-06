const ThemeManager = {
    THEME_KEY: 'site_theme',
    DARK: 'dark',
    LIGHT: 'light',

    init() {
        const savedTheme = localStorage.getItem(this.THEME_KEY) || 
            (window.matchMedia('(prefers-color-scheme: dark)').matches ? this.DARK : this.LIGHT);
        
        this.applyTheme(savedTheme);
        this.setupEventListeners();
    },

    setupEventListeners() {
        document.getElementById('themeToggle').addEventListener('click', () => {
            const currentTheme = this.getCurrentTheme();
            const newTheme = currentTheme === this.DARK ? this.LIGHT : this.DARK;
            this.applyTheme(newTheme);
        });

        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
            const newTheme = e.matches ? this.DARK : this.LIGHT;
            this.applyTheme(newTheme);
        });
    },

    applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem(this.THEME_KEY, theme);
        
        const themeIcon = document.getElementById('themeIcon');
        themeIcon.className = theme === this.DARK ? 'fas fa-sun' : 'fas fa-moon';
        
        // Update charts if they exist
        if (window.updateChartsTheme) {
            window.updateChartsTheme(theme);
        }
    },

    getCurrentTheme() {
        return document.documentElement.getAttribute('data-theme') || this.LIGHT;
    }
};

// Initialize theme system
document.addEventListener('DOMContentLoaded', () => {
    ThemeManager.init();
});