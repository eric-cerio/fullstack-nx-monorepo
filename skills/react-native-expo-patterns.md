---
name: react-native-expo-patterns
description: React Native (Expo) patterns for the mobile app. Covers managed workflow, navigation, native modules (camera, notifications, biometrics), OTA updates, offline-first, secure token storage, and platform-specific code.
---

# React Native (Expo) Patterns

## Project Structure

```
apps/mobile/
├── app.json                    # Expo config (name, slug, version, plugins)
├── eas.json                    # EAS Build + Submit config
├── package.json                # Dependencies and scripts
├── tsconfig.json               # Extends tsconfig.base.json
├── src/
│   ├── app/                    # Expo Router file-based routing
│   │   ├── _layout.tsx         # Root layout (AuthProvider, NavigationContainer)
│   │   ├── (auth)/
│   │   │   ├── sign-in.tsx
│   │   │   └── sign-up.tsx
│   │   ├── (tabs)/
│   │   │   ├── _layout.tsx     # Tab navigator layout
│   │   │   ├── index.tsx       # Home tab
│   │   │   ├── schedule.tsx    # Schedule tab
│   │   │   ├── engage.tsx      # Engagement tab (polls, Q&A)
│   │   │   ├── support.tsx     # Support tab
│   │   │   └── profile.tsx     # Profile tab
│   │   ├── check-in.tsx        # QR check-in screen
│   │   └── +not-found.tsx
│   ├── components/
│   │   ├── ui/                 # Shared UI components
│   │   ├── AttendanceCounter.tsx
│   │   ├── PollCard.tsx
│   │   └── QAThread.tsx
│   ├── hooks/
│   │   ├── useAuth.ts          # Auth context + token management
│   │   ├── useSocket.ts        # WebSocket connection hook
│   │   └── useOffline.ts       # Offline detection + cache
│   ├── lib/
│   │   ├── api.ts              # API client with JWT interceptor
│   │   ├── socket.ts           # Socket.io client setup
│   │   └── storage.ts          # SecureStore + MMKV wrappers
│   ├── providers/
│   │   ├── AuthProvider.tsx     # JWT auth context
│   │   └── SocketProvider.tsx   # WebSocket context
│   └── types/                  # Re-exports from packages/shared
│       └── index.ts
├── assets/
│   ├── images/
│   └── fonts/
└── __tests__/
```

## Expo Config

```json
// apps/mobile/app.json
{
  "expo": {
    "name": "Event App",
    "slug": "event-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "scheme": "eventapp",
    "newArchEnabled": true,
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.myorg.eventapp",
      "infoPlist": {
        "NSCameraUsageDescription": "Camera access is needed for QR code check-in",
        "NSFaceIDUsageDescription": "Face ID is used for staff authentication"
      }
    },
    "android": {
      "adaptiveIcon": { "foregroundImage": "./assets/images/adaptive-icon.png" },
      "package": "com.myorg.eventapp",
      "permissions": ["CAMERA"]
    },
    "plugins": [
      "expo-camera",
      "expo-notifications",
      "expo-local-authentication",
      "expo-secure-store",
      ["expo-updates", { "username": "my-org" }]
    ]
  }
}
```

## EAS Build Config

```json
// apps/mobile/eas.json
{
  "cli": { "version": ">= 12.0.0" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "env": { "API_URL": "http://localhost:4000" }
    },
    "preview": {
      "distribution": "internal",
      "env": { "API_URL": "https://staging-api.example.com" }
    },
    "production": {
      "env": { "API_URL": "https://api.example.com" }
    }
  },
  "submit": {
    "production": {
      "ios": { "appleId": "your@email.com", "ascAppId": "123456789" },
      "android": { "serviceAccountKeyPath": "./google-services.json" }
    }
  }
}
```

## Navigation (Expo Router)

```typescript
// apps/mobile/src/app/_layout.tsx
import { Stack } from 'expo-router'
import { AuthProvider } from '@/providers/AuthProvider'
import { SocketProvider } from '@/providers/SocketProvider'

export default function RootLayout() {
  return (
    <AuthProvider>
      <SocketProvider>
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="(auth)" />
          <Stack.Screen name="(tabs)" />
          <Stack.Screen name="check-in" options={{ presentation: 'modal' }} />
        </Stack>
      </SocketProvider>
    </AuthProvider>
  )
}

// apps/mobile/src/app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router'
import { Ionicons } from '@expo/vector-icons'

export default function TabLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#2563EB' }}>
      <Tabs.Screen name="index" options={{ title: 'Home', tabBarIcon: ({ color }) => <Ionicons name="home" size={24} color={color} /> }} />
      <Tabs.Screen name="schedule" options={{ title: 'Schedule', tabBarIcon: ({ color }) => <Ionicons name="calendar" size={24} color={color} /> }} />
      <Tabs.Screen name="engage" options={{ title: 'Engage', tabBarIcon: ({ color }) => <Ionicons name="chatbubbles" size={24} color={color} /> }} />
      <Tabs.Screen name="support" options={{ title: 'Support', tabBarIcon: ({ color }) => <Ionicons name="help-circle" size={24} color={color} /> }} />
      <Tabs.Screen name="profile" options={{ title: 'Profile', tabBarIcon: ({ color }) => <Ionicons name="person" size={24} color={color} /> }} />
    </Tabs>
  )
}
```

## Secure Token Storage

```typescript
// apps/mobile/src/lib/storage.ts
import * as SecureStore from 'expo-secure-store'

// ✅ GOOD: Use SecureStore for tokens (encrypted, keychain-backed)
export async function getAccessToken(): Promise<string | null> {
  return SecureStore.getItemAsync('access_token')
}

export async function setTokens(access: string, refresh: string): Promise<void> {
  await SecureStore.setItemAsync('access_token', access)
  await SecureStore.setItemAsync('refresh_token', refresh)
}

export async function clearTokens(): Promise<void> {
  await SecureStore.deleteItemAsync('access_token')
  await SecureStore.deleteItemAsync('refresh_token')
}

// ❌ BAD: Never store tokens in AsyncStorage (unencrypted)
// import AsyncStorage from '@react-native-async-storage/async-storage'
// AsyncStorage.setItem('token', jwt) // INSECURE
```

## API Client with JWT Interceptor

```typescript
// apps/mobile/src/lib/api.ts
import { getAccessToken, setTokens, clearTokens } from './storage'
import type { ApiResponse } from '@my-org/shared'

const API_BASE = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:4000'

export async function apiClient<T>(
  path: string,
  options?: RequestInit
): Promise<ApiResponse<T>> {
  const token = await getAccessToken()

  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...options?.headers,
    },
  })

  // Handle 401 — attempt token refresh
  if (response.status === 401) {
    const refreshed = await refreshAccessToken()
    if (refreshed) {
      return apiClient(path, options) // Retry with new token
    }
    await clearTokens()
    throw new Error('Session expired')
  }

  return response.json()
}

async function refreshAccessToken(): Promise<boolean> {
  const refreshToken = await SecureStore.getItemAsync('refresh_token')
  if (!refreshToken) return false

  try {
    const res = await fetch(`${API_BASE}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refresh_token: refreshToken }),
    })
    if (!res.ok) return false

    const data = await res.json()
    await setTokens(data.access_token, data.refresh_token)
    return true
  } catch {
    return false
  }
}
```

## QR Code Check-In (expo-camera)

```typescript
// apps/mobile/src/app/check-in.tsx
import { CameraView, useCameraPermissions } from 'expo-camera'
import { useState } from 'react'
import { apiClient } from '@/lib/api'

export default function CheckInScreen() {
  const [permission, requestPermission] = useCameraPermissions()
  const [scanned, setScanned] = useState(false)

  if (!permission?.granted) {
    return <Button title="Grant Camera Access" onPress={requestPermission} />
  }

  const handleBarCodeScanned = async ({ data }: { data: string }) => {
    if (scanned) return
    setScanned(true)

    try {
      const result = await apiClient('/check-in', {
        method: 'POST',
        body: JSON.stringify({ qr_code: data }),
      })
      // Show success animation
    } catch (error) {
      // Show error state
    } finally {
      setTimeout(() => setScanned(false), 3000) // Cooldown
    }
  }

  return (
    <CameraView
      style={{ flex: 1 }}
      barcodeScannerSettings={{ barcodeTypes: ['qr'] }}
      onBarcodeScanned={handleBarCodeScanned}
    />
  )
}
```

## Push Notifications

```typescript
// apps/mobile/src/hooks/useNotifications.ts
import * as Notifications from 'expo-notifications'
import * as Device from 'expo-device'
import { useEffect, useRef } from 'react'
import { Platform } from 'react-native'
import { apiClient } from '@/lib/api'

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
})

export function useNotifications() {
  const notificationListener = useRef<Notifications.EventSubscription>()

  useEffect(() => {
    registerForPushNotifications()

    notificationListener.current = Notifications.addNotificationReceivedListener(
      (notification) => {
        // Handle foreground notification
      }
    )

    return () => notificationListener.current?.remove()
  }, [])
}

async function registerForPushNotifications() {
  if (!Device.isDevice) return // Push doesn't work on simulators

  const { status } = await Notifications.requestPermissionsAsync()
  if (status !== 'granted') return

  const token = (await Notifications.getExpoPushTokenAsync()).data

  // Register token with backend
  await apiClient('/notifications/register', {
    method: 'POST',
    body: JSON.stringify({ push_token: token, platform: Platform.OS }),
  })
}
```

## Offline-First Pattern

```typescript
// apps/mobile/src/hooks/useOffline.ts
import NetInfo from '@react-native-community/netinfo'
import { MMKV } from 'react-native-mmkv'
import { useEffect, useState } from 'react'

const storage = new MMKV()

export function useOffline() {
  const [isOnline, setIsOnline] = useState(true)

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener((state) => {
      setIsOnline(state.isConnected ?? false)
    })
    return unsubscribe
  }, [])

  return { isOnline }
}

// Cache event schedule for offline use
export function cacheSchedule(schedule: EventSchedule[]) {
  storage.set('cached_schedule', JSON.stringify(schedule))
  storage.set('cached_schedule_timestamp', Date.now().toString())
}

export function getCachedSchedule(): EventSchedule[] | null {
  const data = storage.getString('cached_schedule')
  return data ? JSON.parse(data) : null
}
```

## Platform-Specific Code

```typescript
// ✅ Use Platform.OS for small differences
import { Platform, StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  shadow: Platform.select({
    ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.1, shadowRadius: 4 },
    android: { elevation: 4 },
  }),
})

// ✅ Use .ios.tsx / .android.tsx for large differences
// components/BiometricPrompt.ios.tsx — Face ID implementation
// components/BiometricPrompt.android.tsx — Fingerprint implementation
```

## Shared Types with packages/shared

```typescript
// packages/shared/src/types/event.types.ts — used by BOTH web and mobile
export interface Event {
  id: number
  title: string
  description: string
  date: string
  venue: string
  capacity: number
  registered: number
}

// apps/mobile/src/types/index.ts — re-export for convenience
export type { Event, ApiResponse, UserRole } from '@my-org/shared'
```

## Deep Linking

```typescript
// apps/mobile/app.json — scheme config
{
  "expo": {
    "scheme": "eventapp",
    "web": { "bundler": "metro" }
  }
}

// Usage: eventapp://check-in?code=ABC123
// Usage: https://event.example.com/check-in?code=ABC123 (universal link)
```

## Common Commands

```bash
# Development
cd apps/mobile && npx expo start           # Start dev server
cd apps/mobile && npx expo start --ios     # Start on iOS simulator
cd apps/mobile && npx expo start --android # Start on Android emulator

# Testing
turbo test --filter=@my-org/mobile         # Jest unit tests

# Building
eas build --platform ios --profile preview     # iOS preview build
eas build --platform android --profile preview # Android preview build
eas build --platform all --profile production  # Production builds

# OTA Updates
eas update --branch production --message "Content update"

# Submit to stores
eas submit --platform ios --profile production
eas submit --platform android --profile production
```
