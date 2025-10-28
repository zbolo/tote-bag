# Node.js v24 - Native TypeScript Support

This project uses **Node.js v24** which includes native TypeScript support through the `--experimental-strip-types` flag.

## What This Means

### No Build Step Required
- TypeScript files run directly without compilation
- No need for `tsc` or build tools like `ts-node` or `tsx`
- Faster development iteration

### How It Works

Node.js v24 strips TypeScript type annotations at runtime using the `--experimental-strip-types` flag:

```bash
# Development
node --watch --experimental-strip-types src/index.ts

# Production
node --experimental-strip-types src/index.ts
```

### Key Features

1. **Type Stripping**: Types are removed at runtime, not type-checked
2. **No Transpilation**: Code runs as-is with types stripped
3. **Fast Startup**: No build step means faster startup times
4. **ES Modules**: Full ES module support with TypeScript

### What's Supported

- Type annotations on variables, functions, classes
- Interfaces and type aliases
- Enums (const enums are converted to regular objects)
- Decorators (with `experimentalDecorators` in tsconfig.json)
- Import/export with TypeScript

### What's NOT Supported

- `tsx` or JSX syntax (use `.jsx` or `.tsx` with a transpiler)
- Const enums (converted to regular enums)
- `namespace` keyword (use ES modules instead)
- Some advanced TypeScript features

### Type Checking

Since Node.js only strips types (doesn't check them), you should:

1. Use an IDE with TypeScript support (VS Code, WebStorm)
2. Run `tsc --noEmit` in CI/CD for type checking
3. Use ESLint with TypeScript rules

### Project Configuration

**package.json:**
```json
{
  "type": "module",
  "scripts": {
    "dev": "node --watch --experimental-strip-types src/index.ts",
    "start": "node --experimental-strip-types src/index.ts"
  }
}
```

**tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2024",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    ...
  }
}
```

### Benefits for This Project

1. **Simplified Deployment**: No build step in Docker containers
2. **Faster Development**: Instant file changes with `--watch`
3. **Reduced Dependencies**: No `tsx`, `ts-node`, or TypeScript compiler needed at runtime
4. **Native Performance**: Direct execution by Node.js

### Testing

Jest can also run TypeScript directly:

```bash
node --experimental-vm-modules --experimental-strip-types node_modules/jest/bin/jest.js
```

### Docker

Dockerfile is simplified - no build stage needed:

```dockerfile
FROM node:24-alpine
COPY src ./src
CMD ["node", "--experimental-strip-types", "src/index.ts"]
```

## Migration Notes

If migrating from a traditional TypeScript setup:

1. Remove build scripts from package.json
2. Update start scripts to use `--experimental-strip-types`
3. Remove `dist` or `build` directories
4. Keep `tsconfig.json` for IDE support and type checking
5. Update CI/CD to run `tsc --noEmit` for type checking

## References

- [Node.js v24 Release Notes](https://nodejs.org/en/blog/release)
- [TypeScript Stripping Documentation](https://nodejs.org/docs/latest/api/typescript.html)
- [--experimental-strip-types flag](https://nodejs.org/docs/latest/api/cli.html#--experimental-strip-types)

## Future

As Node.js stabilizes TypeScript support, the `--experimental-strip-types` flag will eventually become stable and the default behavior.

---

**Note**: This is an experimental feature in Node.js v24. For production use, ensure you test thoroughly and have a fallback plan.
