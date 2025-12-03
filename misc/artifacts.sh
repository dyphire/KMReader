#!/bin/bash

# Prepare release artifacts for GitHub Release
# Usage: ./artifacts.sh [source_dir] [dest_dir]
# source_dir: Directory containing exported artifacts (default: ./exports)
# dest_dir: Directory to place prepared artifacts (default: ./artifacts)
#
# This script will:
# 1. Rename .ipa files with platform identifiers
# 2. Convert .pkg files to .dmg files (extracts .app from archive)
# 3. Place all prepared artifacts in the destination directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse arguments
SOURCE_DIR="${1:-$PROJECT_ROOT/exports}"
DEST_DIR="${2:-$PROJECT_ROOT/artifacts}"

# Create destination directory
mkdir -p "$DEST_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Preparing Release Artifacts${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Find all .ipa and .pkg files
IPA_FILES=$(find "$SOURCE_DIR" -type f -name "*.ipa" | sort)
PKG_FILES=$(find "$SOURCE_DIR" -type f -name "*.pkg" | sort)

if [ -z "$IPA_FILES" ] && [ -z "$PKG_FILES" ]; then
	echo -e "${RED}No artifacts found in $SOURCE_DIR${NC}"
	ls -la "$SOURCE_DIR" || true
	exit 1
fi

# Process .ipa files
if [ -n "$IPA_FILES" ]; then
	echo -e "${GREEN}Processing .ipa files...${NC}"
	for ipa in $IPA_FILES; do
		# Determine platform from file path
		PLATFORM=""
		if echo "$ipa" | grep -qiE "(KMReader-iOS|ios|iphone)"; then
			PLATFORM="iOS"
		elif echo "$ipa" | grep -qiE "(KMReader-tvOS|tvos|appletv)"; then
			PLATFORM="tvOS"
		else
			# Default to iOS for .ipa files
			PLATFORM="iOS"
		fi

		# Create new filename with platform identifier
		NEW_NAME="KMReader-${PLATFORM}.ipa"
		NEW_PATH="${DEST_DIR}/${NEW_NAME}"

		# Copy to destination
		cp "$ipa" "$NEW_PATH"
		echo -e "  ${GREEN}✓${NC} $(basename "$ipa") -> ${GREEN}$NEW_NAME${NC} (Platform: $PLATFORM)"
	done
	echo ""
fi

# Process .pkg files (convert to .dmg using .app from archive)
if [ -n "$PKG_FILES" ]; then
	echo -e "${GREEN}Converting .pkg files to .dmg...${NC}"

	# If multiple .pkg files exist, only process the latest one (by timestamp)
	# Convert to array and sort by timestamp to get the latest
	PKG_ARRAY=($PKG_FILES)
	if [ ${#PKG_ARRAY[@]} -gt 1 ]; then
		# Extract timestamps and find the latest
		LATEST_PKG=""
		LATEST_TIMESTAMP=""

		for pkg in "${PKG_ARRAY[@]}"; do
			PKG_DIR=$(dirname "$pkg")
			PKG_DIR_NAME=$(basename "$PKG_DIR")
			TIMESTAMP=$(echo "$PKG_DIR_NAME" | sed -E 's/.*_([0-9]{8}_[0-9]{6})_.*/\1/')

			if [ -n "$TIMESTAMP" ] && echo "$TIMESTAMP" | grep -qE '^[0-9]{8}_[0-9]{6}$'; then
				if [ -z "$LATEST_TIMESTAMP" ] || [ "$TIMESTAMP" \> "$LATEST_TIMESTAMP" ]; then
					LATEST_TIMESTAMP="$TIMESTAMP"
					LATEST_PKG="$pkg"
				fi
			fi
		done

		if [ -n "$LATEST_PKG" ]; then
			echo -e "  ${YELLOW}Found ${#PKG_ARRAY[@]} .pkg files, using latest: $(basename "$(dirname "$LATEST_PKG")")${NC}"
			PKG_FILES="$LATEST_PKG"
		fi
	fi

	for pkg in $PKG_FILES; do
		# Determine platform (should be macOS for .pkg)
		PLATFORM="macOS"

		# Extract timestamp from pkg path (e.g., KMReader-macOS_20251203_184811_export/KMReader.pkg)
		# Pattern: KMReader-macOS_TIMESTAMP_export
		PKG_DIR=$(dirname "$pkg")
		PKG_DIR_NAME=$(basename "$PKG_DIR")

		# Extract timestamp from directory name (format: KMReader-macOS_YYYYMMDD_HHMMSS_export)
		TIMESTAMP=$(echo "$PKG_DIR_NAME" | sed -E 's/.*_([0-9]{8}_[0-9]{6})_.*/\1/')

		# Verify timestamp format (should be YYYYMMDD_HHMMSS)
		if [ -z "$TIMESTAMP" ] || ! echo "$TIMESTAMP" | grep -qE '^[0-9]{8}_[0-9]{6}$'; then
			echo -e "  ${RED}✗${NC} Could not extract timestamp from $(basename "$PKG_DIR")"
			echo -e "  ${YELLOW}Skipping $(basename "$pkg")${NC}"
			continue
		fi

		# Find corresponding archive
		ARCHIVE_NAME="KMReader-${PLATFORM}_${TIMESTAMP}.xcarchive"
		ARCHIVE_PATH="$PROJECT_ROOT/archives/$ARCHIVE_NAME"

		# Also check in Xcode's default archive location
		if [ ! -d "$ARCHIVE_PATH" ]; then
			ARCHIVE_DATE=$(echo "$TIMESTAMP" | cut -d'_' -f1)
			ARCHIVE_DATE_FORMATTED="${ARCHIVE_DATE:0:4}-${ARCHIVE_DATE:4:2}-${ARCHIVE_DATE:6:2}"
			ARCHIVE_PATH="$HOME/Library/Developer/Xcode/Archives/$ARCHIVE_DATE_FORMATTED/$ARCHIVE_NAME"
		fi

		if [ ! -d "$ARCHIVE_PATH" ]; then
			echo -e "  ${RED}✗${NC} Archive not found: $ARCHIVE_NAME"
			echo -e "  ${YELLOW}Searched in:${NC}"
			echo -e "    - $PROJECT_ROOT/archives/"
			echo -e "    - $HOME/Library/Developer/Xcode/Archives/$ARCHIVE_DATE_FORMATTED/"
			echo -e "  ${YELLOW}Skipping $(basename "$pkg")${NC}"
			continue
		fi

		# Extract .app from archive
		APP_PATH="$ARCHIVE_PATH/Products/Applications/KMReader.app"

		if [ ! -d "$APP_PATH" ]; then
			echo -e "  ${RED}✗${NC} .app not found in archive: $APP_PATH"
			echo -e "  ${YELLOW}Skipping $(basename "$pkg")${NC}"
			continue
		fi

		# Get base name for DMG
		DMG_NAME="KMReader-${PLATFORM}.dmg"
		DMG_PATH="${DEST_DIR}/${DMG_NAME}"

		# Remove existing DMG if it exists (to allow overwriting)
		if [ -f "$DMG_PATH" ]; then
			rm -f "$DMG_PATH"
		fi

		# Create temporary directory for DMG creation
		TEMP_DIR=$(mktemp -d)
		trap "rm -rf $TEMP_DIR" EXIT

		echo -e "  ${YELLOW}Creating DMG from .app in archive...${NC}"
		echo -e "    Archive: $(basename "$ARCHIVE_PATH")"
		echo -e "    App: $(basename "$APP_PATH")"

		# Copy .app to temp directory
		cp -R "$APP_PATH" "$TEMP_DIR/"

		# Create DMG from the temp directory containing the .app
		# UDZO format = compressed, read-only
		hdiutil create -srcfolder "$TEMP_DIR" -volname "KMReader" -fs HFS+ -format UDZO "$DMG_PATH" >/dev/null

		# Cleanup
		rm -rf "$TEMP_DIR"
		trap - EXIT

		echo -e "  ${GREEN}✓${NC} $(basename "$pkg") -> ${GREEN}$DMG_NAME${NC} (Platform: $PLATFORM)"
	done
	echo ""
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Prepared artifacts:${NC}"
ls -lh "$DEST_DIR"
echo ""
echo -e "${GREEN}✓ Artifacts prepared successfully!${NC}"
