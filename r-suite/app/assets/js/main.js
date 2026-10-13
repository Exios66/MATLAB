document.addEventListener('DOMContentLoaded', function() {
    // Initialize components
    initializeNavigation();
    initializeModals();
    
    // Load default view
    loadView('dashboard');
});

function initializeNavigation() {
    // Handle sidebar navigation
    document.querySelectorAll('.sidebar .nav-link').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const view = e.target.closest('.nav-link').dataset.view;
            loadView(view);
            
            // Update active state
            document.querySelectorAll('.sidebar .nav-link').forEach(l => l.classList.remove('active'));
            e.target.closest('.nav-link').classList.add('active');
        });
    });
}

function initializeModals() {
    // Initialize Bootstrap modals
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => new bootstrap.Modal(modal));
    
    // Settings button
    document.getElementById('settingsBtn').addEventListener('click', () => {
        const settingsModal = new bootstrap.Modal(document.getElementById('settingsModal'));
        settingsModal.show();
    });
}

async function loadView(viewName) {
    const mainContent = document.getElementById('mainContent');
    mainContent.innerHTML = '<div class="text-center"><i class="fas fa-spinner fa-spin fa-3x"></i></div>';
    
    try {
        const response = await fetch(`components/views/${viewName}.html`);
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        const content = await response.text();
        mainContent.innerHTML = content;
        
        // Initialize view-specific features
        if (window[`init${viewName.charAt(0).toUpperCase() + viewName.slice(1)}View`]) {
            window[`init${viewName.charAt(0).toUpperCase() + viewName.slice(1)}View`]();
        }
    } catch (error) {
        console.error('Error loading view:', error);
        mainContent.innerHTML = `
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle me-2"></i>
                Error loading content. Please try again later.
            </div>
        `;
    }
}