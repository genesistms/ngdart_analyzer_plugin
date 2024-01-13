# Current Support

As you can see, we have a long journey ahead. :)

## Features

| Bootstrapping                                         | Validation | Auto-Complete | Navigation | Refactoring |
| ----------------------------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `bootstrap(AppComponent, [MyService, provide(...)]);` | :x:        | :x:           | :x:        | :x:         |

| Template syntax                                                            | Validation | Auto-Complete | Navigation | Refactoring |
| -------------------------------------------------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `<div stringInput="string">`                                               | :x:        | :x:           | :x:        | :x:         |
| `<input [value]="firstName">`                                              | :x:        | :x:           | :x:        | :x:         |
| `<input bind-value="firstName">`                                           | :x:        | :x:           | :x:        | :x:         |
| `<div [attr.role]="myAriaRole">`                                           | :x:        | :x:           | :x:        | :x:         |
| `<div [attr.role.if]="myAriaRole">`                                        | :x:        | :x:           | :x:        | :x:         |
| `<div [class.extra-sparkle]="isDelightful">`                               | :x:        | :x:           | :x:        | :x:         |
| `<div [style.width.px]="mySize">`                                          | :x:        | :x:           | :x:        | :x:         |
| `<button (click)="readRainbow($event)">`                                   | :x:        | :x:           | :x:        | :x:         |
| `<button (keyup.enter)="...">`                                             | :x:        | :x:           | :x:        | :x:         |
| `<button on-click="readRainbow($event)">`                                  | :x:        | :x:           | :x:        | :x:         |
| `<div title="Hello {{ponyName}}">`                                         | :x:        | :x:           | :x:        | :x:         |
| `<p>Hello {{ponyName}}</p>`                                                | :x:        | :x:           | :x:        | :x:         |
| `<my-cmp></my-cmp>`                                                        | :x:        | :x:           | :x:        | :x:         |
| `<my-cmp [(title)]="name">`                                                | :x:        | :x:           | :x:        | :x:         |
| `<video #movieplayer ...></video><button (click)="movieplayer.play()">`    | :x:        | :x:           | :x:        | :x:         |
| `<video directiveWithExportAs #moviePlayer="exportAsValue">`               | :x:        | :x:           | :x:        | :x:         |
| `<video ref-movieplayer ...></video><button (click)="movieplayer.play()">` | :x:        | :x:           | :x:        | :x:         |
| `<p *myUnless="myExpression">...</p>`                                      | :x:        | :x:           | :x:        | :x:         |
| `<p>Card No.: {{cardNumber \| myCardNumberFormatter}}</p>`                 | :x:        | :x:           | :x:        | :x:         |
| `<my-component @deferred>`                                                 | :x:        | :x:           | :x:        | :x:         |

| Built-in directives                                          | Validation | Auto-Complete | Navigation | Refactoring |
| ------------------------------------------------------------ | ---------- | ------------- | ---------- | ----------- |
| `<section *ngIf="showSection">`                              | :x:        | :x:           | :x:        | :x:         |
| `<li *ngFor="let item of list">`                             | :x:        | :x:           | :x:        | :x:         |
| `<div [ngClass]="{active: isActive, disabled: isDisabled}">` | :x:        | :x:           | :x:        | :x:         |

| Forms                            | Validation | Auto-Complete | Navigation | Refactoring |
| -------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `<input [(ngModel)]="userName">` | :x:        | :x:           | :x:        | :x:         |
| `<form #myform="ngForm">`        | :x:        | :x:           | :x:        | :x:         |

| Class decorators                         | Validation | Auto-Complete | Navigation | Refactoring |
| ---------------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `@Component(...) class MyComponent {}`   | :x:        | :x:           | :x:        | :x:         |
| `@View(...) class MyComponent {}`        | :x:        | :x:           | :x:        | :x:         |
| `@Directive(...) class MyDirective {}`   | :x:        | :x:           | :x:        | :x:         |
| `@Directive(...) void directive(...) {}` | :x:        | :x:           | :x:        | :x:         |
| `@Pipe(...) class MyPipe {}`             | :x:        | :x:           | :x:        | :x:         |
| `@Injectable() class MyService {}`       | :x:        | :x:           | :x:        | :x:         |

| Directive configuration                  | Validation | Auto-Complete | Navigation | Refactoring |
| ---------------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `@Directive(property1: value1, ...)`     | :x:        | :x:           | :x:        | :x:         |
| `selector: '.cool-button:not(a)'`        | :x:        | :x:           | :x:        | :x:         |
| `providers: [MyService, provide(...)]`   | :x:        | :x:           | :x:        | :x:         |
| `inputs: ['myprop', 'myprop2: byname']`  | :x:        | :x:           | :x:        | :x:         |
| `outputs: ['myprop', 'myprop2: byname']` | :x:        | :x:           | :x:        | :x:         |

@Component extends @Directive, so the @Directive configuration applies to
components as well

| Component Configuration                    | Validation | Auto-Complete | Navigation | Refactoring |
| ------------------------------------------ | ---------- | ------------- | ---------- | ----------- |
| `viewProviders: [MyService, provide(...)]` | :x:        | :x:           | :x:        | :x:         |
| `template: 'Hello {{name}}'`               | :x:        | :x:           | :x:        | :x:         |
| `templateUrl: 'my-component.html'`         | :x:        | :x:           | :x:        | :x:         |
| `styles: ['.primary {color: red}']`        | :x:        | :x:           | :x:        | :x:         |
| `styleUrls: ['my-component.css']`          | :x:        | :x:           | :x:        | :x:         |
| `directives: [MyDirective, MyComponent]`   | :x:        | :x:           | :x:        | :x:         |
| `pipes: [MyPipe, OtherPipe]`               | :x:        | :x:           | :x:        | :x:         |
| `exports: [Class, Enum, staticFn]`         | :x:        | :x:           | :x:        | :x:         |

| Class field decorators for directives and components  | Validation | Auto-Complete | Navigation | Refactoring |
| ----------------------------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `@Input() myProperty;`                                | :x:        | :x:           | :x:        | :x:         |
| `@Input("name") myProperty;`                          | :x:        | :x:           | :x:        | :x:         |
| `@Output() myEvent = new Stream<X>();`                | :x:        | :x:           | :x:        | :x:         |
| `@Output("name") myEvent = new Stream<X>();`          | :x:        | :x:           | :x:        | :x:         |
| `@Attribute("name") String ctorArg`                   | :x:        | :x:           | :x:        | :x:         |
| `@HostBinding('[class.valid]') isValid;`              | :x:        | :x:           | :x:        | :x:         |
| `@HostListener('click', ['$event']) onClick(e) {...}` | :x:        | :x:           | :x:        | :x:         |
| `@ContentChild(myPredicate) myChildComponent;`        | :x:        | :x:           | :x:        | :x:         |
| `@ContentChildren(myPredicate) myChildComponents;`    | :x:        | :x:           | :x:        | :x:         |
| `@ViewChild(myPredicate) myChildComponent;`           | :x:        | :x:           | :x:        | :x:         |
| `@ViewChildren(myPredicate) myChildComponents;`       | :x:        | :x:           | :x:        | :x:         |

| Transclusions                                    | Validation | Auto-Complete | Navigation | Refactoring |
| ------------------------------------------------ | ---------- | ------------- | ---------- | ----------- |
| `<ng-content></ng-content>`                      | :x:        | :x:           | :x:        | :x:         |
| `<my-comp>text content</my-comp>`                | :x:        | :x:           | :x:        | :x:         |
| `<ng-content select="foo"></ng-content>`         | :x:        | :x:           | :x:        | :x:         |
| `<my-comp><foo></foo></my-comp>`                 | :x:        | :x:           | :x:        | :x:         |
| `<ng-content select=".foo[bar]"></ng-content>`   | :x:        | :x:           | :x:        | :x:         |
| `<my-comp><div class="foo" bar></div></my-comp>` | :x:        | :x:           | :x:        | :x:         |

| Directive and component change detection and lifecycle hooks (implemented as class methods) | Validation | Auto-Complete | Navigation | Refactoring |
| ------------------------------------------------------------------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `MyAppComponent(MyService myService, ...) { ... }`                                          | :x:        | :x:           | :x:        | :x:         |
| `ngOnChanges(changeRecord) { ... }`                                                         | :x:        | :x:           | :x:        | :x:         |
| `ngOnInit() { ... }`                                                                        | :x:        | :x:           | :x:        | :x:         |
| `ngDoCheck() { ... }`                                                                       | :x:        | :x:           | :x:        | :x:         |
| `ngAfterContentInit() { ... }`                                                              | :x:        | :x:           | :x:        | :x:         |
| `ngAfterContentChecked() { ... }`                                                           | :x:        | :x:           | :x:        | :x:         |
| `ngAfterViewInit() { ... }`                                                                 | :x:        | :x:           | :x:        | :x:         |
| `ngAfterViewChecked() { ... }`                                                              | :x:        | :x:           | :x:        | :x:         |
| `ngOnDestroy() { ... }`                                                                     | :x:        | :x:           | :x:        | :x:         |

| Dependency injection configuration            | Validation | Auto-Complete | Navigation | Refactoring |
| --------------------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `provide(MyService, useClass: MyMockService)` | :x:        | :x:           | :x:        | :x:         |
| `provide(MyService, useFactory: myFactory)`   | :x:        | :x:           | :x:        | :x:         |
| `provide(MyValue, useValue: 41)`              | :x:        | :x:           | :x:        | :x:         |

| Routing and navigation                                          | Validation | Auto-Complete | Navigation | Refactoring |
| --------------------------------------------------------------- | ---------- | ------------- | ---------- | ----------- |
| `@RouteConfig(const [ const Route(...) ])`                      | :x:        | :x:           | :x:        | :x:         |
| `<router-outlet></router-outlet>`                               | :x:        | :x:           | :x:        | :x:         |
| `<a [routerLink]="[ '/MyCmp', {myParam: 'value' } ]">`          | :x:        | :x:           | :x:        | :x:         |
| `@CanActivate(() => ...)class MyComponent() {}`                 | :x:        | :x:           | :x:        | :x:         |
| `routerOnActivate(nextInstruction, prevInstruction) { ... }`    | :x:        | :x:           | :x:        | :x:         |
| `routerCanReuse(nextInstruction, prevInstruction) { ... }`      | :x:        | :x:           | :x:        | :x:         |
| `routerOnReuse(nextInstruction, prevInstruction) { ... }`       | :x:        | :x:           | :x:        | :x:         |
| `routerCanDeactivate(nextInstruction, prevInstruction) { ... }` | :x:        | :x:           | :x:        | :x:         |
| `routerOnDeactivate(nextInstruction, prevInstruction) { ... }`  | :x:        | :x:           | :x:        | :x:         |
