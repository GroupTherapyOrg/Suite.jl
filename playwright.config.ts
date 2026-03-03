import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'list',
  timeout: 30000,
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3456',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  ...(!process.env.BASE_URL ? {
    webServer: {
      // Create Suite.jl symlink so /Suite.jl/*.wasm resolves (matches GitHub Pages path)
      command: 'cd docs/dist && ln -sf . Suite.jl 2>/dev/null; cd ../.. && npx serve docs/dist -l 3456',
      port: 3456,
      reuseExistingServer: !process.env.CI,
    },
  } : {}),
});
