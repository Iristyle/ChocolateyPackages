![Logo](http://angularjs.org/img/AngularJS-small.png)
# AngularJs Sublime Text 2 Bundle

This package provides snippets for *all* the available AngularJS api calls.
The snippets are activated both in HTML and CoffeeScript.

Is this a major perversion of the snippet system?  In a way, yes.

Think of it more as a poor mans Intellisense, rather than a series of snippets.
The snippets intentionally overlap with one another, so that only a few simple
mnemonics require memorization, rather than hundreds.

Using this approach, instead of providing a `xyz`,`TAB` style snippet expansion,
`xyz`,`TAB` will load a context-sensitive Sublime completion overlay where the
appropriate snippet can be picked with the arrow keys and an additional TAB. For
example, `ng`,`TAB` in an HTML tag will show all the available ng-* attributes.
This is a little slower approach than the one typically taken with snippets, but
decreases the learning curve over the API surface.  Note that Sublime appears to
have different conditions for showing the completion overlay.  Simply typing
`ng` in a CoffeeScript document will show the completion menu, while the `TAB` is
required in HTML. (This is potentially related to other installed packages)

## Installation

### Automatic

Ensure that you have installed Sublime Package Control following [these instructions][SublimePackage]

Open the Sublime command palette with `Ctrl + Shift + P`, type / select `Package Control: Install Package`,
then from the package control list, type / select `AngularJS (CoffeeScript)`

Note that packages are auto-updating, so as new modifications are made they will automatically be installed.

[Sublime]: http://www.sublimetext.com/dev
[SublimePackage]: http://wbond.net/sublime_packages/package_control/installation


### Manual tweaking of Package Control

This is not recommended, but Package control can be pointed directly at this
GitHub repository rather than using the registry.
Add to `Packages\User\Package Control.sublime-settings`, under the appropriate
keys in the JSON config file.

This file can be opened via the Sublime menu:
`Preferences -> Package Settings -> Package Control -> Settings -- User`

```javascript
{
  "installed_packages":
  [
    "AngularJS (CoffeeScript)"
  ],
  "package_name_map":
  {
    "Sublime-AngularJS-Coffee-Completions": "AngularJS (CoffeeScript)"
  },
  "repositories":
  [
    "https://github.com/EastPoint/Sublime-AngularJS-Coffee-Completions"
  ]
}
```

### Keybindings

Snippet triggers in Sublime are effectively implicit key bindings, that are
always mapped to a series of characters + TAB.  Alternatively, they can be found
on the `Ctrl + Shift + P` menu by typing `Ang` to filter the list.

It is further recommended that a keybinding similar to the following is added
to provide single key combo access to all the currently available snippets.

```javascript
[
  { "keys": ["shift+f3"], "command": "show_overlay",
    "args": {"overlay": "command_palette", "text": "Angular"} }
]
```

To allow for the `$` character to trigger the menu automatically, the following
must be added to the `Preferences.sublime-settings` file.  This file can be opened
by the `Preferences` -> `Settings -- User` menu item.

```javascript
{
	"auto_complete_triggers":
	[
		{
			"characters": "$",
			"selector": "source.coffee, source.js, source.js.embedded.html"
		}
	]
}
```

If you want to disable duplicate `$`s from showing up in the editor when completing,
then you must change the default `word_separators` to the following, in the same user
`Preferences.sublime-settings`

```javascript
{
	"word_separators": "./\\()\"'-:,.;<>~!@#%^&*|+=[]{}`~?"
}
```

__NOTE:__ `auto_complete_triggers` and `word_separators` are siblings in the same JSON
config object.


#### CoffeeScript

The bindings have been selected so that they don't interfere with the standard
CoffeeScript bindings, namely `=`, `-`, `cla`, `log`, `elif`, `el`, `if`, `ifel`,
`#`, `forof`, `forx`, `fori`, `forin`, `req`, `swi`, `ter`, `try` or `unl`

### Sublime Bugs

Unfortunately there are a couple of issues with Sublime at the moment preventing
it from doing a couple of things that would help us out:

* Filtering within the completions overlay doesn't work right when the `$`
character is involved.

* There is no way to add names to a completion like you can for a snippet, so
the `Ctrl + Space` overlay only shows identifiers.

* The tab trigger system in Sublime does not support regular expressions.  So
when dealing with a member function such as `scope.$watch`, there is no way to
reduce the noise in the list when pressing `.$`.  We see *all* completions
starting with `$` rather than only those starting with `.$`, lengthening the list.

* There is no way that I can find to limit the scope of the `ng-*` attributes to
only the HTML tags that they are valid for (i.e. `ng-csp` only belong on `html`)
The best we can do here is to segregate snippets that are attributes vs tags.

* Sublime doesn't have a convention for optional parameters / blocks in snippets.
This is faked by highlighting the block on the first `TAB` so that it may be
deleted, and allowing subsequent `TAB`s to change specific values in the block
if the block is kept. However, Sublime still honors the tabs inside the block
after it's been deleted. In practical terms, this means it may require extra
`TAB` presses to send the cursor to the next replacement point after an
`optional` block has been deleted.

__Please vote up issues [124225][124225] and [124217][124217] if you want to see
these issues resolved!__

[124225]: http://sublimetext.userecho.com/topic/124225-/
[124217]: http://sublimetext.userecho.com/topic/124217-/

Hopefully a future version of Sublime will address these issues, but for now
there are some work-arounds.

The solution at the moment is to provide placeholder snippets for top-level
services such as `$filter`.

A workflow for this would be the following:

```plaintext
`$`, `TAB`
  -> select Angular filter from the menu with `TAB`
  -> `$filter` is inserted into document
  -> `TAB` brings up completions against `$filter`
  -> select specific filter from the menu with `TAB` (such as currency)
  -> `$filter('currency') currency, 'symbol-eg-USD$'` is inserted into document
  and supports `TAB` completion (or chunk deletion)
```

[completions]: http://docs.sublimetext.info/en/latest/extensibility/completions.html

## Tab Triggers

The number of tab triggers is intentionally limited to increase discoverability.
As a convention, most parameters have been stubbed with a value that indicates
the value that should be replaced.  Where functions take multiple possible
parameters, the `|` has been used by convention - i.e. `true|false`

#### tl;dr Version

These are the only triggers used - `$`, `.$`, `ng`, `for`, `is`, `mod`, `dir`,
`fil`, `mock`, `$cookieStore`, `$filter.`, `$http.`, `$httpBackend.`,
`$injector.`, `$interpolate.`, `$location.`, `$log.`, `$provide.`, `$q.`,
`$route.`, `$routeProvider.`, `.error`, `.expect`, `.other`, `.success` and
`.when` ... PHEW


### Directive

All HTML based directives are keyed off the `ng`,`TAB` binding.

|               Directive                |      Binding     |     Context    |
| :------------------------------------- | ---------------: | --------------:|
| [form][form]                           |      `ng`,`TAB`  |   HTML Element |
| [input][input]                         |      `ng`,`TAB`  |   HTML Element |
| [input \[checkbox\]][input-check]      |      `ng`,`TAB`  |   HTML Element |
| [input \[email\]][input-email]         |      `ng`,`TAB`  |   HTML Element |
| [input \[number\]][input-number]       |      `ng`,`TAB`  |   HTML Element |
| [input \[radio\]][input-radio]         |      `ng`,`TAB`  |   HTML Element |
| [input \[text\]][input-text]           |      `ng`,`TAB`  |   HTML Element |
| [input \[url\]][input-url]             |      `ng`,`TAB`  |   HTML Element |
| [input \[email\]][input-email]         |      `ng`,`TAB`  |   HTML Element |
| [ngApp][ngApp]                         |      `ng`,`TAB`  | HTML Attribute |
| [ngBind][ngBind]                       |      `ng`,`TAB`  | HTML Attribute |
| [ngBindHtml][ngBindHtml]               |      `ng`,`TAB`  | HTML Attribute |
| [ngBindHtmlUnsafe][ngBindHtmlUnsafe]   |      `ng`,`TAB`  | HTML Attribute |
| [ngBindTemplate][ngBindTemplate]       |      `ng`,`TAB`  | HTML Attribute |
| [ngChange][ngChange]                   |      `ng`,`TAB`  | HTML Attribute |
| [ngChecked][ngChecked]                 |      `ng`,`TAB`  | HTML Attribute |
| [ngClass][ngClass]                     |      `ng`,`TAB`  | HTML Attribute |
| [ngClassEven][ngClassEven]             |      `ng`,`TAB`  | HTML Attribute |
| [ngClassOdd][ngClassOdd]               |      `ng`,`TAB`  | HTML Attribute |
| [ngClick][ngClick]                     |      `ng`,`TAB`  | HTML Attribute |
| [ngCloak][ngCloak]                     |      `ng`,`TAB`  | HTML Attribute |
| [ngController][ngController]           |      `ng`,`TAB`  | HTML Attribute |
| [ngCsp][ngCsp]                         |      `ng`,`TAB`  | HTML Attribute |
| [ngDblClick][ngDblClick]               |      `ng`,`TAB`  | HTML Attribute |
| [ngDisabled][ngDisabled]               |      `ng`,`TAB`  | HTML Attribute |
| [ngForm][ngForm]                       |      `ng`,`TAB`  |   HTML Element |
| [ngHide][ngHide]                       |      `ng`,`TAB`  | HTML Attribute |
| [ngHref][ngHref]                       |      `ng`,`TAB`  | HTML Attribute |
| [ngInclude][ngInclude]                 |      `ng`,`TAB`  | HTML Attribute |
| [ngInclude][ngInclude]                 |      `ng`,`TAB`  |   HTML Element |
| [ngInit][ngInit]                       |      `ng`,`TAB`  | HTML Attribute |
| [ngList][ngList]                       |      `ng`,`TAB`  | HTML Attribute |
| [ngModel][ngModel]                     |      `ng`,`TAB`  | HTML Attribute |
| [ngMousedown][ngMousedown]             |      `ng`,`TAB`  | HTML Attribute |
| [ngMouseenter][ngMouseenter]           |      `ng`,`TAB`  | HTML Attribute |
| [ngMouseleave][ngMouseleave]           |      `ng`,`TAB`  | HTML Attribute |
| [ngMousemove][ngMousemove]             |      `ng`,`TAB`  | HTML Attribute |
| [ngMouseover][ngMouseover]             |      `ng`,`TAB`  | HTML Attribute |
| [ngMouseup][ngMouseup]                 |      `ng`,`TAB`  | HTML Attribute |
| [ngMultiple][ngMultiple]               |      `ng`,`TAB`  | HTML Attribute |
| [ngNonBindable][ngNonBindable]         |      `ng`,`TAB`  | HTML Attribute |
| [ngPluralize][ngPluralize]             |      `ng`,`TAB`  | HTML Attribute |
| [ngPluralize][ngPluralize]             |      `ng`,`TAB`  |   HTML Element |
| [ngReadonly][ngReadonly]               |      `ng`,`TAB`  | HTML Attribute |
| [ngRepeat][ngRepeat]                   |      `ng`,`TAB`  | HTML Attribute |
| [ngSelected][ngSelected]               |      `ng`,`TAB`  | HTML Attribute |
| [ngShow][ngShow]                       |      `ng`,`TAB`  | HTML Attribute |
| [ngSrc][ngSrc]                         |      `ng`,`TAB`  | HTML Attribute |
| [ngStyle][ngStyle]                     |      `ng`,`TAB`  | HTML Attribute |
| [ngSubmit][ngSubmit]                   |      `ng`,`TAB`  | HTML Attribute |
| [ngSwitch][ngSwitch]                   |      `ng`,`TAB`  | HTML Attribute |
| [ngSwitch][ngSwitch]                   |      `ng`,`TAB`  |   HTML Element |
| [ngSwitch-default][ngSwitch]           |      `ng`,`TAB`  | HTML Attribute |
| [ngSwitch-when][ngSwitch]              |      `ng`,`TAB`  | HTML Attribute |
| [ngTransclude][ngTransclude]           |      `ng`,`TAB`  | HTML Attribute |
| [ngView][ngView]                       |      `ng`,`TAB`  | HTML Attribute |
| [ngView][ngView]                       |      `ng`,`TAB`  |   HTML Element |
| [script][script]                       |      `ng`,`TAB`  |   HTML Element |
| [select][select]                       |      `ng`,`TAB`  |   HTML Element |
| [textarea][textarea]                   |      `ng`,`TAB`  |   HTML Element |

[form]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:form
[input]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:input
[input-check]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:input.checkbox
[input-email]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:input.email
[input-number]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:input.number
[input-radio]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:input.radio
[input-text]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:input.text
[input-url]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:input.url
[ngApp]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngApp
[ngBind]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngBind
[ngBindHtml]: http://code.angularjs.org/1.1.4/docs/api/ngSanitize.directive:ngBindHtml
[ngBindHtmlUnsafe]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngBindHtmlUnsafe
[ngBindTemplate]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngBindTemplate
[ngChange]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngChange
[ngChecked]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngChecked
[ngClass]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngClass
[ngClassEven]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngClassEven
[ngClassOdd]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngClassOdd
[ngClick]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngClick
[ngCloak]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngCloak
[ngController]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngController
[ngCsp]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngCsp
[ngDblClick]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngDblClick
[ngDisabled]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngDisabled
[ngForm]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngForm
[ngHide]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngHide
[ngHref]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngHref
[ngInclude]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngInclude
[ngInit]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngInit
[ngList]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngList
[ngModel]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel
[ngMousedown]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngMousedown
[ngMouseenter]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngMouseenter
[ngMouseleave]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngMouseleave
[ngMousemove]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngMousemove
[ngMouseover]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngMouseover
[ngMouseup]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngMouseup
[ngMultiple]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngMultiple
[ngNonBindable]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngNonBindable
[ngPluralize]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngPluralize
[ngReadonly]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngReadonly
[ngRepeat]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngRepeat
[ngSelected]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngSelected
[ngShow]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngShow
[ngSrc]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngSrc
[ngStyle]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngStyle
[ngSubmit]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngSubmit
[ngSwitch]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngSwitch
[ngTransclude]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngTransclude
[ngView]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngView
[script]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:script
[select]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:select
[textarea]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:textarea

### Module

|        [Module][module] Method       |      Binding       |    Context   |
| :----------------------------------- | -----------------: | ------------:|
| [config][m.config]                   |        `mod`,`TAB` | CoffeeScript |
| [constant][m.constant]               |        `mod`,`TAB` | CoffeeScript |
| [controller][m.controller]           |        `mod`,`TAB` | CoffeeScript |
| [directive][m.directive] (to chain)  |        `dir`,`TAB` | CoffeeScript |
| [directive][dir-complete] (complete) |        `dir`,`TAB` | CoffeeScript |
| [factory][m.factory]                 |        `mod`,`TAB` | CoffeeScript |
| [filter][m.filter]                   |        `mod`,`TAB` | CoffeeScript |
| [provider][m.provider]               |        `mod`,`TAB` | CoffeeScript |
| [run][m.run]                         |        `mod`,`TAB` | CoffeeScript |
| [service][m.service]                 |        `mod`,`TAB` | CoffeeScript |
| [value][m.value]                     |        `mod`,`TAB` | CoffeeScript |

[module]: http://code.angularjs.org/1.1.4/docs/api/angular.Module
[m.config]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#config
[m.constant]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#constant
[m.controller]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#controller
[m.directive]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#directive
[dir-complete]: http://docs.angularjs.org/guide/directive
[m.factory]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#factory
[m.filter]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#filter
[m.provider]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#provider
[m.run]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#run
[m.service]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#service
[m.value]: http://code.angularjs.org/1.1.4/docs/api/angular.Module#value

### Scope

|            Scope Method              |        Binding        |    Context   |
| :----------------------------------- | --------------------: | ------------:|
| [$rootScope][Scope]                  |           `$`,`TAB`   | CoffeeScript |
| [$apply][$s.$apply]                  |           `.$`,`TAB`  | CoffeeScript |
| [$broadcast][$s.$broadcast]          |           `.$`,`TAB`  | CoffeeScript |
| [$destroy][$s.$destroy]              |           `.$`,`TAB`  | CoffeeScript |
| [$digest][$s.$digest]                |           `.$`,`TAB`  | CoffeeScript |
| [$emit][$s.$emit]                    |           `.$`,`TAB`  | CoffeeScript |
| [$eval][$s.$eval]                    |           `.$`,`TAB`  | CoffeeScript |
| [$evalAsync][$s.$evalAsync]          |           `.$`,`TAB`  | CoffeeScript |
| [$id][$s.$id]                        |           `.$`,`TAB`  | CoffeeScript |
| [$new][$s.$new]                      |           `.$`,`TAB`  | CoffeeScript |
| [$on][$s.$on]                        |           `.$`,`TAB`  | CoffeeScript |
| [$watch][$s.$watch]                  |           `.$`,`TAB`  | CoffeeScript |

[$rootScope]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope
[Scope]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope
[$s.$apply]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$apply
[$s.$broadcast]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$broadcast
[$s.$destroy]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$destroy
[$s.$digest]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$digest
[$s.$emit]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$emit
[$s.$eval]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$eval
[$s.$evalAsync]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$evalAsync
[$s.$id]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$id
[$s.$new]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$new
[$s.$on]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$on
[$s.$watch]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootScope.Scope#$watch

### Controller

Covers both [FormController][FormController] and [NgModelController][NgModelController]

|         Controller Method              |        Binding      |    Context   |
| :------------------------------------- | ------------------: | ------------:|
| [$render][c.$render]                   |         `.$`,`TAB`  | CoffeeScript |
| [$setValidity][c.$setValidity]         |         `.$`,`TAB`  | CoffeeScript |
| [$setViewValue][c.$setViewValue]       |         `.$`,`TAB`  | CoffeeScript |
| [$viewValue][c.$viewValue]             |         `.$`,`TAB`  | CoffeeScript |
| [$modelValue][c.$modelValue]           |         `.$`,`TAB`  | CoffeeScript |
| [$parsers][c.$parsers]                 |         `.$`,`TAB`  | CoffeeScript |
| [$formatters][c.$formatters]           |         `.$`,`TAB`  | CoffeeScript |
| [$error][c.$error]                     |         `.$`,`TAB`  | CoffeeScript |
| [$pristine][c.$pristine]               |         `.$`,`TAB`  | CoffeeScript |
| [$dirty][c.$dirty]                     |         `.$`,`TAB`  | CoffeeScript |
| [$valid][c.$valid]                     |         `.$`,`TAB`  | CoffeeScript |
| [$invalid][c.$invalid]                 |         `.$`,`TAB`  | CoffeeScript |

[FormController]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:form.FormController
[NgModelController]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController
[c.$render]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$render
[c.$setValidity]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$setValidity
[c.$setViewValue]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$setViewValue
[c.$viewValue]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$viewValue
[c.$modelValue]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$modelValue
[c.$parsers]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$parsers
[c.$formatters]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$formatters
[c.$error]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$error
[c.$pristine]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$pristine
[c.$dirty]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$dirty
[c.$valid]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$valid
[c.$invalid]: http://code.angularjs.org/1.1.4/docs/api/ng.directive:ngModel.NgModelController#$invalid

### Resource

|              Resource Methods              |      Binding    |    Context   |
| :----------------------------------------- | --------------: | ------------:|
| [$resource][$resource]                     |      `$`,`TAB`  | CoffeeScript |
| [$delete][$r.$methods]                     |     `.$`,`TAB`  | CoffeeScript |
| [$get][$r.$methods]                        |     `.$`,`TAB`  | CoffeeScript |
| [$query][$r.$methods]                      |     `.$`,`TAB`  | CoffeeScript |
| [$remove][$r.$methods]                     |     `.$`,`TAB`  | CoffeeScript |
| [$save][$r.$methods]                       |     `.$`,`TAB`  | CoffeeScript |

[$resource]: http://code.angularjs.org/1.1.4/docs/api/ngResource.$resource
[$r.$methods]: http://code.angularjs.org/1.1.4/docs/api/ngResource.$resource#Returns

### Filter

|           Filter Method                |        Binding      |    Context   |
| :------------------------------------- | ------------------: | ------------:|
| [$filter][$filter]                     |          `$`,`TAB`  | CoffeeScript |
| [currency][currency]                   |    `$filter`,`TAB`  | CoffeeScript |
| [currency][currency]                   |        `fil`,`TAB`  |         HTML |
| [date][date]                           |    `$filter`,`TAB`  | CoffeeScript |
| [date][date]                           |        `fil`,`TAB`  |         HTML |
| [filter][filter]                       |    `$filter`,`TAB`  | CoffeeScript |
| [filter][filter]                       |        `fil`,`TAB`  |         HTML |
| [json][json]                           |    `$filter`,`TAB`  | CoffeeScript |
| [json][json]                           |        `fil`,`TAB`  |         HTML |
| [limitTo][limitTo]                     |    `$filter`,`TAB`  | CoffeeScript |
| [limitTo][limitTo]                     |        `fil`,`TAB`  |         HTML |
| [linky][linky]                         |    `$filter`,`TAB`  | CoffeeScript |
| [linky][linky]                         |        `fil`,`TAB`  |         HTML |
| [lowercase][lowercase]                 |    `$filter`,`TAB`  | CoffeeScript |
| [lowercase][lowercase]                 |        `fil`,`TAB`  |         HTML |
| [number][number]                       |    `$filter`,`TAB`  | CoffeeScript |
| [number][number]                       |        `fil`,`TAB`  |         HTML |
| [orderBy][orderBy]                     |    `$filter`,`TAB`  | CoffeeScript |
| [orderBy][orderBy]                     |        `fil`,`TAB`  |         HTML |
| [uppercase][uppercase]                 |    `$filter`,`TAB`  | CoffeeScript |
| [uppercase][uppercase]                 |        `fil`,`TAB`  |         HTML |

[$filter]: http://code.angularjs.org/1.1.4/docs/api/ng.$filter
[currency]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:currency
[date]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:date
[filter]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:filter
[json]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:json
[limitTo]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:limitTo
[linky]: http://code.angularjs.org/1.1.4/docs/api/ngSanitize.filter:linky
[lowercase]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:lowercase
[number]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:number
[orderBy]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:orderBy
[uppercase]: http://code.angularjs.org/1.1.4/docs/api/ng.filter:uppercase

### Global API

|                Global API                  |      Binding    |    Context   |
| :----------------------------------------- | --------------: | ------------:|
| [angular.bind][angular.bind]               |    `ng`,`TAB`   | CoffeeScript |
| [angular.bootstrap][angular.bootstrap]     |    `ng`,`TAB`   | CoffeeScript |
| [angular.copy][angular.copy]               |    `ng`,`TAB`   | CoffeeScript |
| [angular.element][angular.element]         |    `ng`,`TAB`   | CoffeeScript |
| [angular.equals][angular.equals]           |    `ng`,`TAB`   | CoffeeScript |
| [angular.extend][angular.extend]           |    `ng`,`TAB`   | CoffeeScript |
| [angular.foreach][angular.foreach]         |   `for`,`TAB`   | CoffeeScript |
| [angular.fromJson][angular.fromJson]       |    `ng`,`TAB`   | CoffeeScript |
| [angular.identity][angular.identity]       |    `ng`,`TAB`   | CoffeeScript |
| [angular.injector][angular.injector]       |    `ng`,`TAB`   | CoffeeScript |
| [angular.isArray][angular.isArray]         |    `is`,`TAB`   | CoffeeScript |
| [angular.isDate][angular.isDate]           |    `is`,`TAB`   | CoffeeScript |
| [angular.isDefined][angular.isDefined]     |    `is`,`TAB`   | CoffeeScript |
| [angular.isElement][angular.isElement]     |    `is`,`TAB`   | CoffeeScript |
| [angular.isFunction][angular.isFunction]   |    `is`,`TAB`   | CoffeeScript |
| [angular.isNumber][angular.isNumber]       |    `is`,`TAB`   | CoffeeScript |
| [angular.isObject][angular.isObject]       |    `is`,`TAB`   | CoffeeScript |
| [angular.isString][angular.isString]       |    `is`,`TAB`   | CoffeeScript |
| [angular.isUndefined][angular.isUndefined] |    `is`,`TAB`   | CoffeeScript |
| [angular.lowercase][angular.lowercase]     |    `ng`,`TAB`   | CoffeeScript |
| [angular.module][angular.module]           |   `mod`,`TAB`   | CoffeeScript |
| [angular.noop][angular.noop]               |    `ng`,`TAB`   | CoffeeScript |
| [angular.toJson][angular.toJson]           |    `ng`,`TAB`   | CoffeeScript |
| [angular.uppercase][angular.uppercase]     |    `ng`,`TAB`   | CoffeeScript |
| [angular.version][angular.version]         |    `ng`,`TAB`   | CoffeeScript |

[angular.bind]: http://code.angularjs.org/1.1.4/docs/api/angular.bind
[angular.bootstrap]: http://code.angularjs.org/1.1.4/docs/api/angular.bootstrap
[angular.copy]: http://code.angularjs.org/1.1.4/docs/api/angular.copy
[angular.element]: http://code.angularjs.org/1.1.4/docs/api/angular.element
[angular.equals]: http://code.angularjs.org/1.1.4/docs/api/angular.equals
[angular.extend]: http://code.angularjs.org/1.1.4/docs/api/angular.extend
[angular.forEach]: http://code.angularjs.org/1.1.4/docs/api/angular.forEach
[angular.fromJson]: http://code.angularjs.org/1.1.4/docs/api/angular.fromJson
[angular.identity]: http://code.angularjs.org/1.1.4/docs/api/angular.identity
[angular.injector]: http://code.angularjs.org/1.1.4/docs/api/angular.injector
[angular.isArray]: http://code.angularjs.org/1.1.4/docs/api/angular.isArray
[angular.isDate]: http://code.angularjs.org/1.1.4/docs/api/angular.isDate
[angular.isDefined]: http://code.angularjs.org/1.1.4/docs/api/angular.isDefined
[angular.isElement]: http://code.angularjs.org/1.1.4/docs/api/angular.isElement
[angular.isFunction]: http://code.angularjs.org/1.1.4/docs/api/angular.isFunction
[angular.isNumber]: http://code.angularjs.org/1.1.4/docs/api/angular.isNumber
[angular.isObject]: http://code.angularjs.org/1.1.4/docs/api/angular.isObject
[angular.isString]: http://code.angularjs.org/1.1.4/docs/api/angular.isString
[angular.isUndefined]: http://code.angularjs.org/1.1.4/docs/api/angular.isUndefined
[angular.lowercase]: http://code.angularjs.org/1.1.4/docs/api/angular.lowercase
[angular.module]: http://code.angularjs.org/1.1.4/docs/api/angular.module
[angular.noop]: http://code.angularjs.org/1.1.4/docs/api/angular.noop
[angular.toJson]: http://code.angularjs.org/1.1.4/docs/api/angular.toJson
[angular.uppercase]: http://code.angularjs.org/1.1.4/docs/api/angular.uppercase
[angular.version]: http://code.angularjs.org/1.1.4/docs/api/angular.version

### Http

|                Http Methods              |       Binding     |    Context   |
| :--------------------------------------- | ----------------: | ------------:|
| [$http][$http]                           |        `$`,`TAB`  | CoffeeScript |
| [$http (configured)][$http.usage]        |        `$`,`TAB`  | CoffeeScript |
| [delete][$http.delete]                   |   `$http.`,`TAB`  | CoffeeScript |
| [get][$http.get]                         |   `$http.`,`TAB`  | CoffeeScript |
| [head][$http.head]                       |   `$http.`,`TAB`  | CoffeeScript |
| [jsonp][$http.jsonp]                     |   `$http.`,`TAB`  | CoffeeScript |
| [post][$http.post]                       |   `$http.`,`TAB`  | CoffeeScript |
| [put][$http.put]                         |   `$http.`,`TAB`  | CoffeeScript |
| [defaults][$http.defaults]               |   `$http.`,`TAB`  | CoffeeScript |
| [pendingRequests][$http.pendingRequests] |   `$http.`,`TAB`  | CoffeeScript |
| [.error][$http.Returns]                  |   `.error`,`TAB`  | CoffeeScript |
| [.success][$http.Returns]                | `.success`,`TAB`  | CoffeeScript |

[$http]: http://code.angularjs.org/1.1.4/docs/api/ng.$http
[$http.usage]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#Usage
[$http.delete]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#delete
[$http.get]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#get
[$http.head]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#head
[$http.jsonp]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#jsonp
[$http.post]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#post
[$http.put]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#put
[$http.defaults]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#defaults
[$http.pendingRequests]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#defaults
[$http.Returns]: http://code.angularjs.org/1.1.4/docs/api/ng.$http#Returns

### HttpBackend

Note that `.expect` and `.when` are designed to chain, so we don't bind to
`$httpBackend`

|              HttpBackend Methods             |         Binding       |    Context   |
| :------------------------------------------- | --------------------: | ------------:|
| [$httpBackend][$httpBackend]                 |             `$`,`TAB` | CoffeeScript |
| [expect][$h.expect]                          |       `.expect`,`TAB` | CoffeeScript |
| [expectDELETE][$h.expectDELETE]              |       `.expect`,`TAB` | CoffeeScript |
| [expectGET][$h.expectGET]                    |       `.expect`,`TAB` | CoffeeScript |
| [expectHEAD][$h.expectHEAD]                  |       `.expect`,`TAB` | CoffeeScript |
| [expectJSONP][$h.expectJSONP]                |       `.expect`,`TAB` | CoffeeScript |
| [expectPATCH][$h.expectPATCH]                |       `.expect`,`TAB` | CoffeeScript |
| [expectPOST][$h.expectPOST]                  |       `.expect`,`TAB` | CoffeeScript |
| [expectPUT][$h.expectPUT]                    |       `.expect`,`TAB` | CoffeeScript |
| [flush][$h.flush]                            | `$httpBackend.`,`TAB` | CoffeeScript |
| [resetExpectations][$h.reset]                | `$httpBackend.`,`TAB` | CoffeeScript |
| [verifyNoOutstandingExceptions][$h.verifyEx] | `$httpBackend.`,`TAB` | CoffeeScript |
| [verifyNoOutstandingRequests][$h.verifyReqs] | `$httpBackend.`,`TAB` | CoffeeScript |
| [when][$h.when]                              |         `.when`,`TAB` | CoffeeScript |
| [whenDELETE][$h.whenDELETE]                  |         `.when`,`TAB` | CoffeeScript |
| [whenGET][$h.whenGET]                        |         `.when`,`TAB` | CoffeeScript |
| [whenHEAD][$h.whenHEAD]                      |         `.when`,`TAB` | CoffeeScript |
| [whenJSONP][$h.whenJSONP]                    |         `.when`,`TAB` | CoffeeScript |
| [whenPATCH][$h.whenPATCH]                    |         `.when`,`TAB` | CoffeeScript |
| [whenPOST][$h.whenPOST]                      |         `.when`,`TAB` | CoffeeScript |
| [whenPUT][$h.whenPUT]                        |         `.when`,`TAB` | CoffeeScript |

[$httpBackend]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend
[$h.expect]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#expect
[$h.expectDELETE]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#expectDELETE
[$h.expectGET]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#expectGET
[$h.expectHEAD]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#expectHEAD
[$h.expectJSONP]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#expectJSONP
[$h.expectPATCH]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#expectPATCH
[$h.expectPOST]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#expectPOST
[$h.expectPUT]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#expectPUT
[$h.flush]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#flush
[$h.reset]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#resetExpectations
[$h.verifyEx]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#verifyNoOutstandingExceptions
[$h.verifyReqs]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#verifyNoOutstandingRequests
[$h.when]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#when
[$h.whenDELETE]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#whenDELETE
[$h.whenGET]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#whenGET
[$h.whenHEAD]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#whenHEAD
[$h.whenJSONP]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#whenJSONP
[$h.whenPATCH]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#whenPATCH
[$h.whenPOST]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#whenPOST
[$h.whenPUT]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$httpBackend#whenPUT

### Q

|            Provider Method             |        Binding      |    Context   |
| :------------------------------------- | ------------------: | ------------:|
| [$q][$q]                               |          `$`,`TAB`  | CoffeeScript |
| [all][$q.all]                          |        `$q.`,`TAB`  | CoffeeScript |
| [defer][$q.defer]                      |        `$q.`,`TAB`  | CoffeeScript |
| [reject][$q.reject]                    |        `$q.`,`TAB`  | CoffeeScript |
| [when][$q.when]                        |        `$q.`,`TAB`  | CoffeeScript |

[$q]: http://code.angularjs.org/1.1.4/docs/api/ng.$q
[$q.all]: http://code.angularjs.org/1.1.4/docs/api/ng.$q#all
[$q.defer]: http://code.angularjs.org/1.1.4/docs/api/ng.$q#defer
[$q.reject]: http://code.angularjs.org/1.1.4/docs/api/ng.$q#reject
[$q.when]: http://code.angularjs.org/1.1.4/docs/api/ng.$q#when

### Route

|              Route Method          |          Binding        |    Context   |
| :----------------------------------| ----------------------: | ------------:|
| [$route][$route]                   |               `$`,`TAB` | CoffeeScript |
| [current][$route.current]          |         `$route.`,`TAB` | CoffeeScript |
| [reload][$route.reload]            |         `$route.`,`TAB` | CoffeeScript |
| [routes][$route.routes]            |         `$route.`,`TAB` | CoffeeScript |
| [$routeChangeError][$route.$rce]   |              `.$`,`TAB` | CoffeeScript |
| [$routeChangeStart][$route.$rcst]  |              `.$`,`TAB` | CoffeeScript |
| [$routeChangeSuccess][$route.$rcs] |              `.$`,`TAB` | CoffeeScript |
| [$routeUpdate][$route.$ru]         |              `.$`,`TAB` | CoffeeScript |
| [$routeParams][$routeParams]       |               `$`,`TAB` | CoffeeScript |
| [$routeProvider][$routeProvider]   |               `$`,`TAB` | CoffeeScript |
| [when][$rp.when]                   | `$routeprovider.`,`TAB` | CoffeeScript |
| [otherwise][$rp.other]             |          `.other`,`TAB` | CoffeeScript |

[$route]: http://code.angularjs.org/1.1.4/docs/api/ng.$route
[$route.current]: http://code.angularjs.org/1.1.4/docs/api/ng.$route#current
[$route.reload]: http://code.angularjs.org/1.1.4/docs/api/ng.$route#reload
[$route.routes]: http://code.angularjs.org/1.1.4/docs/api/ng.$route#routes
[$route.$rce]: http://code.angularjs.org/1.1.4/docs/api/ng.$route#$routeChangeError
[$route.$rcst]: http://code.angularjs.org/1.1.4/docs/api/ng.$route#$routeChangeStart
[$route.$rcs]: http://code.angularjs.org/1.1.4/docs/api/ng.$route#$routeChangeSuccess
[$route.$ru]: http://code.angularjs.org/1.1.4/docs/api/ng.$route#$routeUpdate
[$routeParams]: http://code.angularjs.org/1.1.4/docs/api/ng.$routeParams
[$routeProvider]: http://code.angularjs.org/1.1.4/docs/api/ng.$routeProvider
[$rp.when]: http://code.angularjs.org/1.1.4/docs/api/ng.$routeProvider#when
[$rp.other]: http://code.angularjs.org/1.1.4/docs/api/ng.$routeProvider#otherwise

### Cookie

|            Cookie Method             |        Binding        |    Context   |
| :----------------------------------- | --------------------: | ------------:|
| [$cookies][$cookies]                 |           `$`,`TAB`   | CoffeeScript |
| [$cookieStore][$cookieStore]         |           `$`,`TAB`   | CoffeeScript |
| [get][$c.get]                        | `$cookiestore.`,`TAB` | CoffeeScript |
| [put][$c.put]                        | `$cookiestore.`,`TAB` | CoffeeScript |
| [remove][$c.remove]                  | `$cookiestore.`,`TAB` | CoffeeScript |

[$cookies]: http://code.angularjs.org/1.1.4/docs/api/ngCookies.$cookies
[$cookieStore]: http://code.angularjs.org/1.1.4/docs/api/ngCookies.$cookieStore
[$c.get]: http://code.angularjs.org/1.1.4/docs/api/ngCookies.$cookieStore#get
[$c.put]: http://code.angularjs.org/1.1.4/docs/api/ngCookies.$cookieStore#put
[$c.remove]: http://code.angularjs.org/1.1.4/docs/api/ngCookies.$cookieStore#remove

### Location

|            Location Method           |      Binding       |    Context   |
| :----------------------------------- | -----------------: | ------------:|
| [$injector][$injector]               |          `$`,`TAB` | CoffeeScript |
| [absUrl][$l.absUrl]                  | `$location.`,`TAB` | CoffeeScript |
| [hash][$l.hash] (get & set)          | `$location.`,`TAB` | CoffeeScript |
| [host][$l.host]                      | `$location.`,`TAB` | CoffeeScript |
| [path][$l.path] (get & set)          | `$location.`,`TAB` | CoffeeScript |
| [port][$l.port]                      | `$location.`,`TAB` | CoffeeScript |
| [protocol][$l.protocol]              | `$location.`,`TAB` | CoffeeScript |
| [replace][$l.replace]                | `$location.`,`TAB` | CoffeeScript |
| [search][$l.search] (get & set)      | `$location.`,`TAB` | CoffeeScript |
| [url][$l.url] (get & set)            | `$location.`,`TAB` | CoffeeScript |

[$location]: http://code.angularjs.org/1.1.4/docs/api/ng.$location
[$l.absUrl]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#absUrl
[$l.hash]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#hash
[$l.host]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#host
[$l.path]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#path
[$l.port]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#port
[$l.protocol]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#protocol
[$l.replace]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#replace
[$l.search]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#search
[$l.url]: http://code.angularjs.org/1.1.4/docs/api/ng.$location#url

### Log

|               Log Method             |    Binding      |    Context   |
| :----------------------------------- | --------------: | ------------:|
| [$log][$log]                         |      `$`,`TAB`  | CoffeeScript |
| [error][$log.error]                  |  `$log.`,`TAB`  | CoffeeScript |
| [info][$log.info]                    |  `$log.`,`TAB`  | CoffeeScript |
| [log][$log.log]                      |  `$log.`,`TAB`  | CoffeeScript |
| [warn][$log.warn]                    |  `$log.`,`TAB`  | CoffeeScript |

[$log]: http://code.angularjs.org/1.1.4/docs/api/ng.$log
[$log.error]: http://code.angularjs.org/1.1.4/docs/api/ng.$log#error
[$log.info]: http://code.angularjs.org/1.1.4/docs/api/ng.$log#info
[$log.log]: http://code.angularjs.org/1.1.4/docs/api/ng.$log#log
[$log.warn]: http://code.angularjs.org/1.1.4/docs/api/ng.$log#warn

### Mock

|            Mock Method                 |        Binding      |    Context   |
| :------------------------------------- | ------------------: | ------------:|
| [angular.mock.debug][mock.debug]       |       `mock`,`TAB`  | CoffeeScript |
| [angular.mock.inject][mock.inject]     |       `mock`,`TAB`  | CoffeeScript |
| [angular.mock.module][mock.module]     |       `mock`,`TAB`  | CoffeeScript |
| [angular.mock.TzDate][mock.TzDate]     |       `mock`,`TAB`  | CoffeeScript |
| [$log.assertEmpty][$log.assertEmpty]   |      `$log.`,`TAB`  | CoffeeScript |
| [$log.reset][$log.reset]               |      `$log.`,`TAB`  | CoffeeScript |
| [$log.logs][$log.logs]                 |      `$log.`,`TAB`  | CoffeeScript |
| [$timeout.flush][$timeout.flush]       |  `$timeout.`,`TAB`  | CoffeeScript |

[mock.debug]: http://code.angularjs.org/1.1.4/docs/api/angular.mock.debug
[mock.inject]: http://code.angularjs.org/1.1.4/docs/api/angular.mock.inject
[mock.module]: http://code.angularjs.org/1.1.4/docs/api/angular.mock.module
[mock.TzDate]: http://code.angularjs.org/1.1.4/docs/api/angular.mock.debug
[$log.assertEmpty]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$log#assertEmpty
[$log.reset]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$log#reset
[$log.logs]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$log#logs
[$timeout.flush]: http://code.angularjs.org/1.1.4/docs/api/ngMock.$timeout#flush

### Injector

|            Injector Method           |      Binding       |    Context   |
| :----------------------------------- | -----------------: | ------------:|
| [$injector][$injector]               |          `$`,`TAB` | CoffeeScript |
| [annotate][$i.annotate]              | `$injector.`,`TAB` | CoffeeScript |
| [get][$i.get]                        | `$injector.`,`TAB` | CoffeeScript |
| [instantiate][$i.instantiate]        | `$injector.`,`TAB` | CoffeeScript |
| [invoke][$i.invoke]                  | `$injector.`,`TAB` | CoffeeScript |

[$injector]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$injector
[$i.annotate]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$injector#annotate
[$i.get]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$injector#get
[$i.instantiate]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$injector#instantiate
[$i.invoke]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$injector#invoke

### Interpolate

|            Injector Method           |        Binding        |    Context   |
| :----------------------------------- | --------------------: | ------------:|
| [$interpolate][$interpolate]         |             `$`,`TAB` | CoffeeScript |
| [endSymbol][$in.endSymbol]           | `$interpolate.`,`TAB` | CoffeeScript |
| [startsymbol][$in.startsymbol]       | `$interpolate.`,`TAB` | CoffeeScript |

[$interpolate]: http://code.angularjs.org/1.1.4/docs/api/ng.$interpolate
[$in.endSymbol]: http://code.angularjs.org/1.1.4/docs/api/ng.$interpolate#endSymbol
[$in.startSymbol]: http://code.angularjs.org/1.1.4/docs/api/ng.$interpolate#startSymbol

### Provide

|            Provider Method             |        Binding      |    Context   |
| :------------------------------------- | ------------------: | ------------:|
| [$provide][$provide]                   |          `$`,`TAB`  | CoffeeScript |
| [constant][$p.constant]                |  `$provide.`,`TAB`  | CoffeeScript |
| [decorator][$p.decorator]              |  `$provide.`,`TAB`  | CoffeeScript |
| [factory][$p.factory]                  |  `$provide.`,`TAB`  | CoffeeScript |
| [provider][$p.provider]                |  `$provide.`,`TAB`  | CoffeeScript |
| [service][$p.service]                  |  `$provide.`,`TAB`  | CoffeeScript |
| [value][$p.value]                      |  `$provide.`,`TAB`  | CoffeeScript |

[$provide]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$provide
[$p.constant]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$provide#constant
[$p.decorator]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$provide#decorator
[$p.factory]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$provide#factory
[$p.provider]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$provide#provider
[$p.service]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$provide#service
[$p.value]: http://code.angularjs.org/1.1.4/docs/api/AUTO.$provide#value

### Other Services

|                 Service                |   Binding   |    Context   |
| :------------------------------------- | ----------: |-------------:|
| [$anchorScroll][$anchorScroll]         |  `$`,`TAB`  | CoffeeScript |
| [$cacheFactory][$cacheFactory]         |  `$`,`TAB`  | CoffeeScript |
| [$compile][$compile]                   |  `$`,`TAB`  | CoffeeScript |
| [$controller][$controller]             |  `$`,`TAB`  | CoffeeScript |
| [$document][$document]                 |  `$`,`TAB`  | CoffeeScript |
| [$exceptionHandler][$exceptionHandler] |  `$`,`TAB`  | CoffeeScript |
| [$locale][$locale]                     |  `$`,`TAB`  | CoffeeScript |
| [$parse][$parse]                       |  `$`,`TAB`  | CoffeeScript |
| [$rootElement][$rootElement]           |  `$`,`TAB`  | CoffeeScript |
| [$templateCache][$templateCache]       |  `$`,`TAB`  | CoffeeScript |
| [$timeout][$timeout]                   |  `$`,`TAB`  | CoffeeScript |
| [$window][$window]                     |  `$`,`TAB`  | CoffeeScript |

[$anchorScroll]: http://code.angularjs.org/1.1.4/docs/api/ng.$anchorScroll
[$cacheFactory]: http://code.angularjs.org/1.1.4/docs/api/ng.$cacheFactory
[$compile]: http://code.angularjs.org/1.1.4/docs/api/ng.$compile
[$controller]: http://code.angularjs.org/1.1.4/docs/api/ng.$controller
[$document]: http://code.angularjs.org/1.1.4/docs/api/ng.$document
[$exceptionHandler]: http://code.angularjs.org/1.1.4/docs/api/ng.$exceptionHandler
[$locale]: http://code.angularjs.org/1.1.4/docs/api/ng.$locale
[$parse]: http://code.angularjs.org/1.1.4/docs/api/ng.$parse
[$rootElement]: http://code.angularjs.org/1.1.4/docs/api/ng.$rootElement
[$templateCache]: http://code.angularjs.org/1.1.4/docs/api/ng.$templateCache
[$timeout]: http://code.angularjs.org/1.1.4/docs/api/ng.$timeout
[$window]: http://code.angularjs.org/1.1.4/docs/api/ng.$window

## Future Improvements

* It would be nice to provide inline docs through SublimeCodeIntel in a vein
similar to the [ones provided for jQuery][jQuery].

* [SublimeErl][SublimeErl] also provides some pretty fancy features which would
be nice to integrate

[jQuery]: https://github.com/Kronuz/SublimeCodeIntel/blob/master/libs/codeintel2/catalogs/jquery.cix
[SublimeErl]: https://github.com/ostinelli/SublimErl

## Making Contributions

* When editing `.sublime-snippets` files, __always__ use real tab characters for
indentation on a newline following a crlf/lf.  Sublime will automatically insert
spaces if your user settings specify spacing for indentation.

* Write CoffeeScript that will pass coffeelint


## Thanks

Original inspiration was from the [AngularJS tmbundle][tmbundle], which was
targeted at JavaScript and a small set of mnemonics for common operations.  This
is designed to be more comprehensive.

[tmbundle]: github.com/ProLoser/AngularJs.tmbundle.git
