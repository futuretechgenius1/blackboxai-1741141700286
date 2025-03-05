// PayTrack Pro - Main JavaScript

// Global configuration
const config = {
    appName: 'PayTrack Pro',
    apiBaseUrl: '/api',
    dateFormat: 'YYYY-MM-DD',
    timeFormat: 'HH:mm',
    currency: 'USD'
};

// Loading spinner management
const loadingSpinner = {
    show() {
        document.getElementById('loading-spinner')?.classList.remove('hidden');
    },
    hide() {
        document.getElementById('loading-spinner')?.classList.add('hidden');
    }
};

// Toast notifications
const toast = {
    show(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `fixed bottom-4 right-4 px-6 py-3 rounded-lg shadow-lg ${
            type === 'success' ? 'bg-green-500' :
            type === 'error' ? 'bg-red-500' :
            type === 'warning' ? 'bg-yellow-500' :
            'bg-blue-500'
        } text-white slide-in z-50`;
        toast.textContent = message;
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.remove();
        }, 3000);
    }
};

// Form validation
const validateForm = (form) => {
    const requiredFields = form.querySelectorAll('[required]');
    let isValid = true;

    requiredFields.forEach(field => {
        if (!field.value.trim()) {
            isValid = false;
            field.classList.add('border-red-500');
            
            const errorMessage = field.dataset.errorMessage || 'This field is required';
            const existingError = field.nextElementSibling;
            
            if (!existingError || !existingError.classList.contains('error-message')) {
                const error = document.createElement('p');
                error.className = 'text-red-500 text-sm mt-1 error-message';
                error.textContent = errorMessage;
                field.parentNode.insertBefore(error, field.nextSibling);
            }
        } else {
            field.classList.remove('border-red-500');
            const existingError = field.nextElementSibling;
            if (existingError?.classList.contains('error-message')) {
                existingError.remove();
            }
        }
    });

    return isValid;
};

// Date formatting
const formatDate = (date, format = config.dateFormat) => {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    
    return format
        .replace('YYYY', year)
        .replace('MM', month)
        .replace('DD', day);
};

// Currency formatting
const formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: config.currency
    }).format(amount);
};

// API calls wrapper
const api = {
    async get(endpoint) {
        try {
            loadingSpinner.show();
            const response = await fetch(`${config.apiBaseUrl}${endpoint}`);
            if (!response.ok) throw new Error('Network response was not ok');
            return await response.json();
        } catch (error) {
            toast.show(error.message, 'error');
            throw error;
        } finally {
            loadingSpinner.hide();
        }
    },

    async post(endpoint, data) {
        try {
            loadingSpinner.show();
            const response = await fetch(`${config.apiBaseUrl}${endpoint}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            if (!response.ok) throw new Error('Network response was not ok');
            return await response.json();
        } catch (error) {
            toast.show(error.message, 'error');
            throw error;
        } finally {
            loadingSpinner.hide();
        }
    }
};

// Event Handlers
document.addEventListener('DOMContentLoaded', () => {
    // Initialize form validation
    document.querySelectorAll('form').forEach(form => {
        form.addEventListener('submit', (e) => {
            if (!validateForm(form)) {
                e.preventDefault();
                toast.show('Please fill in all required fields', 'error');
            }
        });
    });

    // Initialize tooltips
    document.querySelectorAll('[data-tooltip]').forEach(element => {
        element.addEventListener('mouseenter', (e) => {
            const tooltip = document.createElement('div');
            tooltip.className = 'absolute bg-gray-900 text-white px-2 py-1 rounded text-sm z-50';
            tooltip.textContent = e.target.dataset.tooltip;
            document.body.appendChild(tooltip);

            const rect = e.target.getBoundingClientRect();
            tooltip.style.top = `${rect.top - tooltip.offsetHeight - 5}px`;
            tooltip.style.left = `${rect.left + (rect.width - tooltip.offsetWidth) / 2}px`;
        });

        element.addEventListener('mouseleave', () => {
            document.querySelectorAll('.tooltip').forEach(t => t.remove());
        });
    });
});

// Export utilities for use in other scripts
window.PayTrackPro = {
    config,
    toast,
    api,
    formatDate,
    formatCurrency,
    validateForm
};
