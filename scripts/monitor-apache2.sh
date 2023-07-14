#!/bin/bash

# Check if Apache2 service is running
if systemctl is-active --quiet apache2; then
    echo "Apache2 service is already running."
else
    echo "Apache2 service is not running. Starting it..."
    # Start Apache2 service
    sudo systemctl start apache2
    if [ $? -eq 0 ]; then
        echo "Apache2 service started successfully."
    else
        echo "Failed to start Apache2 service."
    fi
fi
