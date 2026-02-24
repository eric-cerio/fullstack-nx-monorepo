---
description: Review React Native (Expo) mobile app code for navigation, platform handling, secure storage, offline patterns, and production readiness. Invokes the mobile-specialist agent.
---

# Mobile Review Command

Invokes the **mobile-specialist** agent to perform a comprehensive review of React Native/Expo mobile app code.

## What This Command Does

1. **Scan Mobile App Structure** — Identify the Expo app directory, navigation setup, and configuration files (`app.json`, `eas.json`)
2. **Review Expo Configuration** — Check production readiness: build profiles, signing, OTA updates, push notification credentials
3. **Audit Secure Storage** — Verify JWT tokens use `expo-secure-store`, not AsyncStorage
4. **Review Navigation Architecture** — Validate Expo Router file-based routing, deep linking, auth guards, and modal handling
5. **Check Platform-Specific Code** — Ensure iOS and Android differences are handled (safe areas, back button, keyboard behavior)
6. **Evaluate Offline Patterns** — Verify network state monitoring, local caching, offline mutation queues
7. **Assess Performance** — FlatList optimization, image caching, memo usage, animation thread
8. **Verify Accessibility** — Labels, touch targets, screen reader support, dynamic font scaling
9. **Review Real-Time Mobile Patterns** — WebSocket reconnection on app foreground, push notification handling

## Steps

1. Read `app.json` / `app.config.ts` and `eas.json` for configuration issues
2. Scan navigation directory structure for Expo Router patterns
3. Search for `AsyncStorage` usage — flag any token storage in AsyncStorage
4. Review `FlatList` usage for optimization props (`keyExtractor`, `getItemLayout`, `memo`)
5. Check for `expo-secure-store`, `expo-notifications`, `expo-updates`, `expo-camera` usage
6. Verify platform-specific handling (`Platform.OS`, `SafeAreaView`, keyboard behavior)
7. Review offline patterns and network state monitoring
8. Check accessibility labels and touch target sizes
9. Produce a categorized review with CRITICAL, HIGH, and MEDIUM findings

## When to Use

- After implementing a new mobile screen or feature
- Before submitting a build to App Store or Google Play
- When adding real-time features (WebSocket) to the mobile app
- When integrating new Expo modules (camera, notifications, updates)
- During mobile-specific code review before merging to main

## Usage Examples

```
/mobile-review
```

Review the entire mobile app codebase for production readiness.

```
/mobile-review apps/mobile/src/screens/EventDetail.tsx
```

Review a specific screen for mobile best practices.

```
/mobile-review --focus=security
```

Focus the review on secure storage, token handling, and auth patterns.

## Integration

After mobile review:

- Fix CRITICAL issues before proceeding
- Use `/code-review` for general code quality on shared logic
- Use `/realtime-review` if WebSocket patterns are involved
- Use `/plan` to plan fixes for architectural issues identified

## Related Agent

`agents/mobile-specialist.md`
