#!/bin/sh
# Simple application runner

echo "Simple App v1.0.0"
echo "================="
echo ""
echo "This is an example application created with mksfx"
echo ""

# Load configuration
if [ -f "config.txt" ]; then
  echo "Loading configuration..."
  . ./config.txt
  echo "App Name: $APP_NAME"
  echo "Environment: $ENVIRONMENT"
fi

echo ""
echo "Application running successfully!"
