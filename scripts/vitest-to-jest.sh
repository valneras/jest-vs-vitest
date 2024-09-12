#!/bin/bash


join_by() {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

# Go to src directory
ROOT_DIR="$(pwd)"
# Navigate to the src directory
if cd "$ROOT_DIR/src"; then
  echo "Navigated to src directory."
else
  echo "Error: Could not navigate to src directory. Exiting."
  exit 1
fi

# Find all *.spec.js, *.spec.ts, *.spec.jsx, and *.spec.tsx files. For each of them:
# - Replace "jest.*" with "vi.*"
# - Attempt to replace "jest.mock" and "jest.requireActual" with "vi.mock" and "vi.importActual", respectively.
# - Add "import { describe, expect, it, … } from 'vitest';" to the top of the file
files=$(find . -type f -name "*.spec.js" -o -name "*.spec.ts" -o -name "*.spec.jsx" -o -name "*.spec.tsx" -o -name "*.test.js" -o -name "*.test.ts" -o -name "*.test.jsx" -o -name "*.test.tsx" | grep -v "node_modules")

for file in $files; do
  echo "Processing $file"

  # Replace "jest.clearAllMocks" with "vi.clearAllMocks"
  sed -i '' 's/vi.clearAllMocks/jest.clearAllMocks/g' $file

  # Replace "jest.fn" with "vi.fn"
  sed -i '' 's/vi.fn/jest.fn/g' $file

  # Replace "jest.mocked" with "vi.mocked"
  sed -i '' 's/vi.mocked/jest.mocked/g' $file

  # Replace "jest.resetAllMocks" with "vi.resetAllMocks"
  sed -i '' 's/vi.resetAllMocks/jest.resetAllMocks/g' $file

  # Replace "jest.resetModules" with "vi.resetModules"
  sed -i '' 's/vi.resetModules/jest.resetModules/g' $file

  # Replace "jest.spyOn" with "vi.spyOn"
  sed -i '' 's/vi.spyOn/jest.spyOn/g' $file

  # Replace "jest.useFakeTimers" with "vi.useFakeTimers"
  sed -i '' 's/vi.useFakeTimers/jest.useFakeTimers/g' $file
  sed -i '' 's/vi.runAllTimers/jest.runAllTimers/g' $file

  # Replace "jest.useRealTimers" with "vi.useRealTimers"
  sed -i '' 's/vi.useRealTimers/jest.useRealTimers/g' $file

  # Replace "advanceTimers: jest.advanceTimersByTime" with "advanceTimers: vi.advanceTimersByTime.bind(vi)"
  sed -i '' 's/advanceTimers: vi.advanceTimersByTime/advanceTimers: jest.advanceTimersByTime.bind(vi)/g' $file

  # Detect jest.mock(). Since vi.mock() uses ESM modules, chances are manual changes
  # are going to be necessary. So, we'll print a warning.
  if grep -q "vi.mock(" $file; then
    echo "  Warning: $file contained jest.mock(). You'll likely need to manually fix vi.mock() implementation."

    sed -i '' 's/vi.mock/jest.mock/g' $file
  fi

  # Detect jest.requireActual(). Since vi.importActual() uses ESM modules, chances are
  # manual changes are going to be necessary. So, we'll print a warning.
  if grep -q "vi.requireActual(" $file; then
    echo "  Warning: $file contained jest.requireActual(). You'll likely need to manually fix vi.importActual() implementation."

    sed -i '' 's/vi.requireActual/jest.importActual/g' $file
  fi

  # Replace remaining vi after reformating
   sed -i '' 's/ = vi/ = jest/g' $file

  # Clear the vi imports
  sed -i '' '/import { .* } from "vitest";/d' $file

  echo "  Done"
done

#npm run lint:fix
