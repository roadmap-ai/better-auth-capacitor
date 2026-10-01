// Lazy-loaded module reference (cached to avoid re-importing)
let _SecureStorageMod: typeof import('@aparajita/capacitor-secure-storage') | null = null

async function getSecureStorage() {
  if (!_SecureStorageMod) {
    _SecureStorageMod = await import('@aparajita/capacitor-secure-storage')
  }
  return _SecureStorageMod.SecureStorage
}

/**
 * Secure (Keychain / Keystore backed) string storage.
 * Uses the plugin's string-only methods so values are never converted to Date/JSON.
 */
export async function getItem(key: string): Promise<string | null> {
  const storage = await getSecureStorage()
  return storage.getItem(key)
}

export async function setItem(key: string, value: string): Promise<void> {
  const storage = await getSecureStorage()
  await storage.setItem(key, value)
}

export async function removeItem(key: string): Promise<void> {
  const storage = await getSecureStorage()
  await storage.removeItem(key)
}
