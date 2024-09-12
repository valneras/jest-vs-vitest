# JestVsVitest

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 18.0.2.

## Running unit tests 
### With Jest

To execute the unit tests with Jest:
``
npm run test:jest
``

### With Vitest

To execute the unit tests with Vitest:
``
npm run test:vitest
``

### Debugging

Add a breakpoint in file `src/app/app.component.spec.ts`

Run debugger of your IDE with Vitest extension for Jetbrains or VSCode.

## Setup of this repo

Commands launched to init this repo:

```
ng new --directory .   
npm install @analogjs/platform --save-dev
ng g @analogjs/platform:setup-vitest --project jest-vs-vitest
npm uninstall @types/jasmine jasmine-core karma karma-chrome-launcher karma-coverage karma-jasmine karma-jasmine-html-reporter
npm install --save-dev @types/jest jest jest-preset-angular
```
