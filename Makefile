# FreshVeg — Developer Makefile
# Usage: make <target>

.PHONY: help setup run build test clean deploy-functions deploy-rules format analyze

## ── Meta ─────────────────────────────────────────────────────────────────────

help:
	@echo ""
	@echo "FreshVeg — Available Commands"
	@echo "─────────────────────────────────────────────────────"
	@echo "  make setup            Install deps + configure Firebase"
	@echo "  make run              Run app in debug mode"
	@echo "  make run-release      Run app in release mode"
	@echo "  make build-apk        Build release APK"
	@echo "  make build-ipa        Build iOS release archive"
	@echo "  make test             Run all tests"
	@echo "  make format           Auto-format all Dart files"
	@echo "  make analyze          Run dart analyze"
	@echo "  make clean            Clean build artifacts"
	@echo "  make deploy-all       Deploy functions + firestore + storage rules"
	@echo "  make deploy-functions Deploy Cloud Functions only"
	@echo "  make deploy-rules     Deploy Firestore + Storage rules"
	@echo "  make emulate          Start Firebase emulator suite"
	@echo "  make icons            Generate app icons (requires flutter_launcher_icons)"
	@echo ""

## ── Setup ────────────────────────────────────────────────────────────────────

setup:
	@echo "→ Installing Flutter dependencies..."
	flutter pub get
	@echo "→ Installing Cloud Functions dependencies..."
	cd functions && npm install
	@echo "→ Done. Now run: flutterfire configure --project=<your-project-id>"

## ── Run ──────────────────────────────────────────────────────────────────────

run:
	flutter run

run-release:
	flutter run --release

run-android:
	flutter run -d android

run-ios:
	flutter run -d ios

## ── Build ────────────────────────────────────────────────────────────────────

build-apk:
	flutter build apk --release --split-per-abi
	@echo "APKs saved to build/app/outputs/flutter-apk/"

build-apk-fat:
	flutter build apk --release
	@echo "APK saved to build/app/outputs/flutter-apk/app-release.apk"

build-aab:
	flutter build appbundle --release
	@echo "AAB saved to build/app/outputs/bundle/release/app-release.aab"

build-ipa:
	flutter build ipa --release

## ── Test ─────────────────────────────────────────────────────────────────────

test:
	flutter test --reporter expanded

test-coverage:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	@echo "Coverage report: coverage/html/index.html"

## ── Code Quality ─────────────────────────────────────────────────────────────

format:
	dart format lib/ test/ --fix

analyze:
	dart analyze lib/

fix:
	dart fix --apply lib/

## ── Clean ────────────────────────────────────────────────────────────────────

clean:
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/
	cd functions && rm -rf node_modules/
	@echo "Clean complete"

## ── Firebase Deploy ──────────────────────────────────────────────────────────

deploy-all:
	firebase deploy

deploy-functions:
	cd functions && npm install
	firebase deploy --only functions

deploy-rules:
	firebase deploy --only firestore:rules,storage

deploy-indexes:
	firebase deploy --only firestore:indexes

## ── Emulator ─────────────────────────────────────────────────────────────────

emulate:
	firebase emulators:start

emulate-functions:
	firebase emulators:start --only functions,firestore

## ── Assets ───────────────────────────────────────────────────────────────────

icons:
	flutter pub run flutter_launcher_icons

gen:
	dart run build_runner build --delete-conflicting-outputs
