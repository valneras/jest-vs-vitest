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
files=$(find . -type f \( -name "*.spec.js" -o -name "*.spec.ts" -o -name "*.spec.jsx" -o -name "*.spec.tsx" -o -name "*.test.js" -o -name "*.test.ts" -o -name "*.test.jsx" -o -name "*.test.tsx" \) -not -path "*/node_modules/*")

for file in $files; do
  echo "Processing $file"

  # Detect if file contains "from ["']vitest["']". If so, skip it.
  if grep -q "from ['\"]vitest['\"]" $file; then
    echo "  Test file appears to have already been migrated to Vitest. Skipping"
    continue
  fi

  # Replace "jest.clearAllMocks" with "vi.clearAllMocks"
  sed -i '' 's/jest.clearAllMocks/vi.clearAllMocks/g' $file

  # Replace "jest.fn" with "vi.fn"
  sed -i '' 's/jest.fn/vi.fn/g' $file

  # Replace "jest.mocked" with "vi.mocked"
  sed -i '' 's/jest.mocked/vi.mocked/g' $file

  # Replace "jest.resetAllMocks" with "vi.resetAllMocks"
  sed -i '' 's/jest.resetAllMocks/vi.resetAllMocks/g' $file

  # Replace "jest.resetModules" with "vi.resetModules"
  sed -i '' 's/jest.resetModules/vi.resetModules/g' $file

  # Replace "jest.spyOn" with "vi.spyOn"
  sed -i '' 's/jest.spyOn/vi.spyOn/g' $file

  # Replace "jest.useFakeTimers" with "vi.useFakeTimers"
  sed -i '' 's/jest.useFakeTimers/vi.useFakeTimers/g' $file
  sed -i '' 's/jest.runAllTimers/vi.runAllTimers/g' $file

  # Replace "jest.useRealTimers" with "vi.useRealTimers"
  sed -i '' 's/jest.useRealTimers/vi.useRealTimers/g' $file

  # Replace "advanceTimers: jest.advanceTimersByTime" with "advanceTimers: vi.advanceTimersByTime.bind(vi)"
  sed -i '' 's/jest.advanceTimersByTime/vi.advanceTimersByTime.bind(vi)/g' $file

  # Detect jest.mock(). Since vi.mock() uses ESM modules, chances are manual changes
  # are going to be necessary. So, we'll print a warning.
  if grep -q "jest.mock(" $file; then
    echo "  Warning: $file contained jest.mock(). You'll likely need to manually fix vi.mock() implementation."

    sed -i '' 's/jest.mock/vi.mock/g' $file
  fi

  # Detect jest.requireActual(). Since vi.importActual() uses ESM modules, chances are
  # manual changes are going to be necessary. So, we'll print a warning.
  if grep -q "jest.requireActual(" $file; then
    echo "  Warning: $file contained jest.requireActual(). You'll likely need to manually fix vi.importActual() implementation."

    sed -i '' 's/jest.requireActual/vi.importActual/g' $file
  fi

  # Replace jest.setTimeout() with vi.setConfig({ testTimeout: N })
  if grep -q "jest.setTimeout(" $file; then
    echo "  TODO"
  fi

  # Define list of required imports for each file

  # Clear the array of imports
  imports=()

  # If file contains "afterEach", add it to the list of required imports
  if grep -q "afterEach" $file; then
    imports[0]="afterEach"
  fi
  # If file contains "beforeEach", add it to the list of required imports
  if grep -q "beforeEach" $file; then
    imports[1]="beforeEach"
  fi
  imports[2]="describe"
  imports[3]="expect"
  imports[4]="it"
  # If file contains "vi.", add it to the list of required imports
  if grep -q "vi\." $file; then
    imports[5]="vi"
  fi

  # Join list of required imports into a string
  imports_string=$(join_by ", " "${imports[@]}")

  # Add "import { … } from 'vitest';" to the top of the file.
  sed -i '' '1i\
import { '"$imports_string"' } from "vitest";
' $file

  # Replace remaining jest after reformating
  sed -i '' 's/ = jest/ = vi/g' $file


  echo "  Done"
done

#npm run lint:fix
