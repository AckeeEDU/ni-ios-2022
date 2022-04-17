# NI-IOS 2022

## Přednášky

### 01 Advanced Swift

* Protocol oriented programming
* Generics
* Custom operators
* Property wrappers

### 02 UIKit

* Project structure
* Storyboards, View debugger
* UIView, UIViewController, lifecycle
* Frame vs. bounds
* Autolayout, Layout guides
* NSConstraints, SnapKit
* Package managers, Swift Package Manager
* UIStackView, UINavigationController, UITabBarController

### 03 SwiftUI

* VStack, HStack, ZStack, Text
* ViewModifiers
* SwiftUI layout system
* NavigationView, programatic navigation
* GeometryReader

### 04 Async/Await

### 05 Combine

### 06 Architectures – MVVM, Clean architecure, DI

* Why architecture matters?
* MVVM, Clean Architecture comparison
* DI

### 07 Architectures - Composable Architecture

### 08 DI + Testy

### 09 Widget
- Widget extension
- Automatic code signing
- Static widget configuration

### 10 Pušky + extensions
- Code signing?

### 11 Widget

### 12 Rezerva

## Semestrální úloha

Semestrální práce bude váš jediný velký domácí úkol, na základě kterého získáte známku. Ideálně středně velká aplikace s 6 - 10 obrazovkami. Ze cvik máte k dispozici spoustu věcí a technologií, které můžete použít. Opět ideálně, když ukážete co nejvíce z nich. Vyžadovaná bude nějaká architektura (nechceme vidět všechnu logiku ve `View`), závislosti používané pomocí DI a ideálně i testíky. 🤓 Narozdíl od bakalářského předmětu budeme při hodnocení dbát na strukturu a vzhled kódu, ať tam není 🤮.

Konkrétní požadavky:

* pohrát si se Swiftem - použít nějakou hezkou vlastní extension, generickou funkci nebo třeba pokročilejší enum
* použít nějakou architekturu MVVM, Clean Architecture, Composable Architecture nebo něco dle vašeho výběru
* použít Combine nebo async/await
* určitě alespoň pár testů
* s testy je spojeno dependency injection - nedělat žádné globální singletony apod.
* použít cokoliv víc advanced
	* pohrát si s animacemi
	* udělat today widget, appku na hodinky, klávesnici
	* klidně i něco, co se na cvikách nebude dělat (nějaké pokročilejší video, rozpoznávání obličejů, zvuky, ...)

Už nejsme na bakaláři, takže hlavně dbejte na kód, ať nemáte volání API singletonu z `viewDidLoad`. 👎 Ideálně má vzniknout téměř **appstore ready appka** - hezký design, UX, ikonka, launchscreen etc.

Příklady zajímavých API:

* [Pokémon](https://pokeapi.co)
* [StarWars](https://swapi.dev)
* [Covid](https://onemocneni-aktualne.mzcr.cz/api/v2/covid-19)
* [Odpadkové koše v Praze](https://golemioapi.docs.apiary.io/#reference/waste/waste-collection-yards/get-all-waste-collection-yards)
* [Metaweather](https://www.metaweather.com/api/)
* [Rick & Morty](https://rickandmortyapi.com/documentation)
