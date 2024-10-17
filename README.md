[![Dart SDK Version](https://badgen.net/pub/sdk-version/pull_down_button)](https://pub.dev/packages/flutter_simple_country_picker)
[![Pub Version](https://img.shields.io/pub/v/pull_down_button)](https://pub.dev/packages/flutter_simple_country_picker)
[![Pub Likes](https://img.shields.io/pub/likes/pull_down_button)](https://pub.dev/packages/flutter_simple_country_picker)
<!-- [![popularity](https://img.shields.io/pub/popularity/flutter_simple_country_picker?logo=dart)](https://pub.dev/packages/flutter_simple_country_picker/score) -->
[![codecov](https://codecov.io/gh/ziqq/flutter_simple_country_picker/graph/badge.svg?token=fpn56ea0L8)](https://codecov.io/gh/ziqq/flutter_simple_country_picker)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)



# flutter_simple_country_picker



<img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/master/.docs/images/full_example_light.png" width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/master/.docs/images/full_example_dark.png"  width="385px"> <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/master/.docs/images/filtered_example_light.png" width="385px">  <img src="https://raw.githubusercontent.com/ziqq/flutter_simple_country_picker/refs/heads/master/.docs/images/filtered_example_dark.png" width="385px">



##  Description

The Flutter package that provides an easy-to-use country selection widget. It allows users to select a country from a comprehensive list of countries, making it simple to integrate country picking functionality into your Flutter applications. The package supports Android, iOS, and web platforms, and offers customization options for fonts and styles.



## Getting Started

 Add the package to your pubspec.yaml:

 ```yaml
 flutter_simple_country_picker: <version>
 ```



## Installation

 In your dart file, import the library:

 ```Dart
 import 'package:flutter_simple_country_picker/flutter_simple_country_picker.dart';
 ```


## Example

Add the `CountriesLocalization.delegate` in the list of your app delegates. Set supported locales [Locale('ru'), Locale('en')]. And set your locale `ru` or `en`.

```Dart
MaterialApp(
  locale: const Locale('ru'), // Locale('en'),
  supportedLocales: const <Locale>[
    Locale('ru'),
    Locale('en'),
  ],
  localizationsDelegates: [
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,

    /// Add [CountriesLocalization] in app [localizationsDelegates]
    CountriesLocalization.delegate,
  ],
  home: HomePage(),
);
```

Example usage of the `showCountryPicker` function:

```Dart
showCountryPicker(
  context: context,
  exclude: ['RU', 'EN'],
  onDone: () {
    print('CountryPicker dismissed');
  },
  onSelect: (Country country) {
    print('Selected country: ${country.displayName}');
  },
);
```

Optional argumets of the `showCountryPicker` function:

| Argument            | Description                                                                         |
|---------------------|-------------------------------------------------------------------------------------|
| `exclude`           | List of countries to exclude from the list.                                         |
| `filter`            | List of countries to filter the list.                                               |
| `favorite`          | List of countries to show at the top of the list.                                   |
| `showPhoneCode`     | Displays the phone code before the country name.                                    |
| `showWorldWide`     | Shows the "World Wide" option at the beginning of the list.                         |
| `useAutofocus`      | Automatically opens the keyboard when the picker is loaded.                         |
| `showSearch`        | Enables or disables the search bar.                                                 |
| `isDismissible`     | Allows the user to close the modal by swiping it down.                              |
| `isScrollControlled`| Controls the scrolling behavior of the modal window.                                |
| `useHaptickFeedback`| Enables haptic feedback.                                                            |
| `useSafeArea`       | Enables the safe area for the modal window.                                         |
| `onSelect`          | Callback when the select a country.                                                 |
| `onDone`            | Callback when the CountryPicker is dismissed, whether a country is selected or not. |


## All countries list

| Flag   | Country                        | Code       | Phone mask        |
|--------|--------------------------------|------------|-------------------|
| 🇦🇫     | Afghanistan                    | +93        | 00 000 000        |
| 🇦🇱     | Albania                        | +355       | 00 000 0000       |
| 🇩🇿     | Algeria                        | +213       | 00 000 0000       |
| 🇦🇸     | American Samoa                 | +1684      | 000 0000          |
| 🇦🇩     | Andorra                        | +376       | 000 000           |
| 🇦🇴     | Angola                         | +244       | 000 000 000       |
| 🇦🇮     | Anguilla                       | +1264      | 000 0000          |
| 🇦🇶     | Antarctica                     | +672       | 00 000            |
| 🇦🇬     | Antigua and Barbuda            | +1268      | 000 0000          |
| 🇦🇷     | Argentina                      | +54        | 00 0000 0000      |
| 🇦🇲     | Armenia                        | +374       | 00 000 000        |
| 🇦🇼     | Aruba                          | +297       | 000 0000          |
| 🇦🇺     | Australia                      | +61        | 00 0000 0000      |
| 🇦🇹     | Austria                        | +43        | 000 0000 0000     |
| 🇦🇿     | Azerbaijan                     | +994       | 00 000 0000       |
| 🇧🇸     | Bahamas                        | +1242      | 000 0000          |
| 🇧🇭     | Bahrain                        | +973       | 0000 0000         |
| 🇧🇩     | Bangladesh                     | +880       | 000 000 0000      |
| 🇧🇧     | Barbados                       | +1246      | 000 0000          |
| 🇧🇾     | Belarus                        | +375       | 00 000 0000       |
| 🇧🇪     | Belgium                        | +32        | 000 000 000       |
| 🇧🇿     | Belize                         | +501       | 000 0000          |
| 🇧🇯     | Benin                          | +229       | 00 00 00 00       |
| 🇧🇲     | Bermuda                        | +1441      | 000 0000          |
| 🇧🇹     | Bhutan                         | +975       | 00 00 00          |
| 🇧🇴     | Bolivia                        | +591       | 00 000 000        |
| 🇧🇦     | Bosnia and Herzegovina         | +387       | 00 000 000        |
| 🇧🇼     | Botswana                       | +267       | 00 000 000        |
| 🇧🇷     | Brazil                         | +55        | 00 0000 0000      |
| 🇮🇴     | British Indian Ocean Territory | +246       | 000 0000          |
| 🇻🇬     | British Virgin Islands         | +1284      | 000 0000          |
| 🇧🇳     | Brunei                         | +673       | 000 0000          |
| 🇧🇬     | Bulgaria                       | +359       | 00 000 000        |
| 🇧🇫     | Burkina Faso                   | +226       | 00 00 00 00       |
| 🇧🇮     | Burundi                        | +257       | 00 00 00 00       |
| 🇨🇻     | Cape Verde                     | +238       | 00 00 00          |
| 🇰🇭     | Cambodia                       | +855       | 00 000 000        |
| 🇨🇲     | Cameroon                       | +237       | 00 00 00 00       |
| 🇨🇦     | Canada                         | +1         | 000 000 0000      |
| 🇰🇾     | Cayman Islands                 | +1345      | 000 0000          |
| 🇨🇫     | Central African Republic       | +236       | 00 00 00 00       |
| 🇹🇩     | Chad                           | +235       | 00 00 00 00       |
| 🇨🇱     | Chile                          | +56        | 00 0000 0000      |
| 🇨🇳     | China                          | +86        | 000 0000 0000     |
| 🇨🇽     | Christmas Island               | +61        | 00 0000 0000      |
| 🇨🇨     | Cocos (Keeling) Islands        | +61        | 00 0000 0000      |
| 🇨🇴     | Colombia                       | +57        | 000 000 0000      |
| 🇰🇲     | Comoros                        | +269       | 00 00 00          |
| 🇨🇬     | Congo                          | +242       | 00 000 000        |
| 🇨🇩     | Congo (DRC)                    | +243       | 00 000 0000       |
| 🇨🇰     | Cook Islands                   | +682       | 00 000            |
| 🇨🇷     | Costa Rica                     | +506       | 0000 0000         |
| 🇨🇮     | Côte d'Ivoire                  | +225       | 00 000 000        |
| 🇭🇷     | Croatia                        | +385       | 00 000 000        |
| 🇨🇺     | Cuba                           | +53        | 00 000 000        |
| 🇨🇼     | Curaçao                        | +5999      | 000 0000          |
| 🇨🇾     | Cyprus                         | +357       | 00 000 000        |
| 🇨🇿     | Czech Republic                 | +420       | 000 000 000       |
| 🇩🇰     | Denmark                        | +45        | 00 00 00 00       |
| 🇩🇯     | Djibouti                       | +253       | 00 00 00 00       |
| 🇩🇲     | Dominica                       | +1767      | 000 0000          |
| 🇩🇴     | Dominican Republic             | +1809      | 000 0000          |
| 🇪🇨     | Ecuador                        | +593       | 00 000 0000       |
| 🇪🇬     | Egypt                          | +20        | 000 000 0000      |
| 🇸🇻     | El Salvador                    | +503       | 00 00 00 00       |
| 🇬🇶     | Equatorial Guinea              | +240       | 00 00 00 00       |
| 🇪🇷     | Eritrea                        | +291       | 00 000 000        |
| 🇪🇪     | Estonia                        | +372       | 000 000 00        |
| 🇪🇹     | Ethiopia                       | +251       | 00 000 000        |
| 🇫🇰     | Falkland Islands               | +500       | 000 000           |
| 🇫🇴     | Faroe Islands                  | +298       | 000 000           |
| 🇫🇯     | Fiji                           | +679       | 000 000           |
| 🇫🇮     | Finland                        | +358       | 00 000 000        |
| 🇫🇷     | France                         | +33        | 00 00 00 00 00    |
| 🇬🇫     | French Guiana                  | +594       | 000 000 000       |
| 🇵🇫     | French Polynesia               | +689       | 00 00 00          |
| 🇬🇦     | Gabon                          | +241       | 00 00 00 00       |
| 🇬🇲     | Gambia                         | +220       | 00 00 00          |
| 🇬🇪     | Georgia                        | +995       | 000 000 000       |
| 🇩🇪     | Germany                        | +49        | 0000 000000       |
| 🇬🇭     | Ghana                          | +233       | 00 000 0000       |
| 🇬🇮     | Gibraltar                      | +350       | 0000 0000         |
| 🇬🇷     | Greece                         | +30        | 000 000 0000      |
| 🇬🇱     | Greenland                      | +299       | 00 00 00          |
| 🇬🇩     | Grenada                        | +1473      | 000 0000          |
| 🇬🇵     | Guadeloupe                     | +590       | 000 00 00 00      |
| 🇬🇺     | Guam                           | +1671      | 000 0000          |
| 🇬🇹     | Guatemala                      | +502       | 0000 0000         |
| 🇬🇬     | Guernsey                       | +44        |                   |
| 🇬🇳     | Guinea                         | +224       | 00 00 00 00       |
| 🇬🇼     | Guinea-Bissau                  | +245       | 00 00 00          |
| 🇬🇾     | Guyana                         | +592       | 000 0000          |
| 🇭🇹     | Haiti                          | +509       | 00 00 000         |
| 🇭🇳     | Honduras                       | +504       | 0000 0000         |
| 🇭🇰     | Hong Kong                      | +852       | 0000 0000         |
| 🇭🇺     | Hungary                        | +36        | 00 000 000        |
| 🇮🇸     | Iceland                        | +354       | 000 0000          |
| 🇮🇳     | India                          | +91        | 0000 000 000      |
| 🇮🇩     | Indonesia                      | +62        | 0000 000 000      |
| 🇮🇷     | Iran                           | +98        | 0000 000 000      |
| 🇮🇶     | Iraq                           | +964       | 00 000 0000       |
| 🇮🇪     | Ireland                        | +353       | 000 000 000       |
| 🇮🇲     | Isle of Man                    | +44        |                   |
| 🇮🇱     | Israel                         | +972       | 00 000 0000       |
| 🇮🇹     | Italy                          | +39        | 000 000 0000      |
| 🇯🇲     | Jamaica                        | +1876      | 000 0000          |
| 🇯🇵     | Japan                          | +81        | 000 000 0000      |
| 🇯🇪     | Jersey                         | +44        |                   |
| 🇯🇴     | Jordan                         | +962       | 00 000 0000       |
| 🇰🇿     | Kazakhstan                     | +7         | 000 000 0000      |
| 🇰🇪     | Kenya                          | +254       | 000 000 000       |
| 🇰🇮     | Kiribati                       | +686       | 00 000            |
| 🇰🇼     | Kuwait                         | +965       | 0000 0000         |
| 🇰🇬     | Kyrgyzstan                     | +996       | 000 000 000       |
| 🇱🇦     | Laos                           | +856       | 00 000 000        |
| 🇱🇻     | Latvia                         | +371       | 00 000 000        |
| 🇱🇧     | Lebanon                        | +961       | 00 000 000        |
| 🇱🇸     | Lesotho                        | +266       | 000 0000          |
| 🇱🇷     | Liberia                        | +231       | 00 000 000        |
| 🇱🇾     | Libya                          | +218       | 00 000 000        |
| 🇱🇮     | Liechtenstein                  | +423       | 000 0000          |
| 🇱🇹     | Lithuania                      | +370       | 00 000 000        |
| 🇱🇺     | Luxembourg                     | +352       | 00 00 00 00       |
| 🇲🇴     | Macau                          | +853       | 000 000 000       |
| 🇲🇰     | Macedonia                      | +389       | 00 000 000        |
| 🇲🇬     | Madagascar                     | +261       | 00 00 000 00      |
| 🇲🇼     | Malawi                         | +265       | 00 0000 000       |
| 🇲🇾     | Malaysia                       | +60        | 00 000 0000       |
| 🇲🇻     | Maldives                       | +960       | 000 0000          |
| 🇲🇱     | Mali                           | +223       | 00 00 00 00       |
| 🇲🇹     | Malta                          | +356       | 0000 0000         |
| 🇲🇭     | Marshall Islands               | +692       | 000 0000          |
| 🇲🇶     | Martinique                     | +596       | 000 00 00 00      |
| 🇲🇷     | Mauritania                     | +222       | 00 00 00 00       |
| 🇲🇺     | Mauritius                      | +230       | 000 0000          |
| 🇲🇽     | Mexico                         | +52        | 000 000 0000      |
| 🇫🇲     | Micronesia                     | +691       | 000 0000          |
| 🇲🇩     | Moldova                        | +373       | 00 00 00 00       |
| 🇲🇨     | Monaco                         | +377       | 00 000 000        |
| 🇲🇳     | Mongolia                       | +976       | 00 000 000        |
| 🇲🇪     | Montenegro                     | +382       | 00 000 000        |
| 🇲🇸     | Montserrat                     | +1664      | 000 0000          |
| 🇲🇦     | Morocco                        | +212       | 00 0000 0000      |
| 🇲🇿     | Mozambique                     | +258       | 00 00 00 00       |
| 🇲🇲     | Myanmar                        | +95        | 00 000 000        |
| 🇳🇦     | Namibia                        | +264       | 00 000 0000       |
| 🇳🇷     | Nauru                          | +674       | 00 000            |
| 🇳🇵     | Nepal                          | +977       | 000 000 0000      |
| 🇳🇱     | Netherlands                    | +31        | 000 000 0000      |
| 🇳🇨     | New Caledonia                  | +687       | 00 00 00          |
| 🇳🇿     | New Zealand                    | +64        | 00 000 0000       |
| 🇳🇮     | Nicaragua                      | +505       | 0000 0000         |
| 🇳🇪     | Niger                          | +227       | 00 00 00 00       |
| 🇳🇬     | Nigeria                        | +234       | 000 000 0000      |
| 🇳🇺     | Niue                           | +683       | 00 000            |
| 🇳🇫     | Norfolk Island                 | +672       | 00 000            |
| 🇲🇵     | Northern Mariana Islands       | +1670      | 000 0000          |
| 🇳🇴     | Norway                         | +47        | 000 00 000        |
| 🇴🇲     | Oman                           | +968       | 0000 0000         |
| 🇵🇰     | Pakistan                       | +92        | 000 000 0000      |
| 🇵🇼     | Palau                          | +680       | 000 0000          |
| 🇵🇦     | Panama                         | +507       | 000 0000          |
| 🇵🇬     | Papua New Guinea               | +675       | 000 0000          |
| 🇵🇾     | Paraguay                       | +595       | 000 000 000       |
| 🇵🇪     | Peru                           | +51        | 00 000 000        |
| 🇵🇭     | Philippines                    | +63        | 000 000 0000      |
| 🇵🇳     | Pitcairn Islands               | +64        |                   |
| 🇵🇱     | Poland                         | +48        | 000 000 000       |
| 🇵🇹     | Portugal                       | +351       | 000 000 000       |
| 🇵🇷     | Puerto Rico                    | +1         | 000 000 0000      |
| 🇶🇦     | Qatar                          | +974       | 0000 0000         |
| 🇷🇪     | Réunion                        | +262       | 000 00 00 00      |
| 🇷🇴     | Romania                        | +40        | 000 000 000       |
| 🇷🇺     | Russia                         | +7         | 000 000 0000      |
| 🇷🇼     | Rwanda                         | +250       | 0000 0000         |
| 🇰🇳     | Saint Kitts and Nevis          | +1869      | 000 0000          |
| 🇱🇨     | Saint Lucia                    | +1758      | 000 0000          |
| 🇻🇨     | Saint Vincent and the Grenadin | +1784      | 000 0000          |
| 🇼🇸     | Samoa                          | +685       | 00 000            |
| 🇸🇲     | San Marino                     | +378       | 00 00 00          |
| 🇸🇹     | São Tomé and Príncipe          | +239       | 00 00 00          |
| 🇸🇦     | Saudi Arabia                   | +966       | 000 000 000       |
| 🇸🇳     | Senegal                        | +221       | 00 000 000        |
| 🇷🇸     | Serbia                         | +381       | 00 000 000        |
| 🇸🇨     | Seychelles                     | +248       | 000 0000          |
| 🇸🇱     | Sierra Leone                   | +232       | 00 000 000        |
| 🇸🇬     | Singapore                      | +65        | 0000 0000         |
| 🇸🇽     | Sint Maarten                   | +1721      | 000 0000          |
| 🇸🇰     | Slovakia                       | +421       | 00 000 000        |
| 🇸🇮     | Slovenia                       | +386       | 00 000 000        |
| 🇸🇧     | Solomon Islands                | +677       | 00 000            |
| 🇸🇴     | Somalia                        | +252       | 00 000 000        |
| 🇿🇦     | South Africa                   | +27        | 000 000 0000      |
| 🇬🇸     | South Georgia                  | +500       | 000 000           |
| 🇰🇷     | South Korea                    | +82        | 00 000 0000       |
| 🇸🇸     | South Sudan                    | +211       | 00 000 000        |
| 🇪🇸     | Spain                          | +34        | 000 000 000       |
| 🇱🇰     | Sri Lanka                      | +94        | 00 000 000        |
| 🇸🇩     | Sudan                          | +249       | 00 000 000        |
| 🇸🇷     | Suriname                       | +597       | 000 0000          |
| 🇸🇿     | Swaziland                      | +268       | 0000 0000         |
| 🇸🇪     | Sweden                         | +46        | 000 000 000       |
| 🇨🇭     | Switzerland                    | +41        | 000 000 0000      |
| 🇸🇾     | Syria                          | +963       | 0000 000 000      |
| 🇹🇼     | Taiwan                         | +886       | 0000 000 000      |
| 🇹🇯     | Tajikistan                     | +992       | 00 000 0000       |
| 🇹🇿     | Tanzania                       | +255       | 00 000 0000       |
| 🇹🇭     | Thailand                       | +66        | 000 000 0000      |
| 🇹🇱     | Timor-Leste                    | +670       | 000 0000          |
| 🇹🇬     | Togo                           | +228       | 00 00 00 00       |
| 🇹🇰     | Tokelau                        | +690       | 00 000            |
| 🇹🇴     | Tonga                          | +676       | 00 000            |
| 🇹🇹     | Trinidad and Tobago            | +1868      | 000 0000          |
| 🇹🇳     | Tunisia                        | +216       | 00 000 000        |
| 🇹🇷     | Turkey                         | +90        | 000 000 0000      |
| 🇹🇲     | Turkmenistan                   | +993       | 00 000 000        |
| 🇹🇻     | Tuvalu                         | +688       | 00 000            |
| 🇺🇬     | Uganda                         | +256       | 000 0000 000      |
| 🇺🇦     | Ukraine                        | +380       | 00 000 0000       |
| 🇦🇪     | United Arab Emirates           | +971       | 00 000 0000       |
| 🇬🇧     | United Kingdom                 | +44        | 0000 000 000      |
| 🇺🇸     | United States                  | +1         | 000 000 0000      |
| 🇺🇾     | Uruguay                        | +598       | 0000 0000         |
| 🇺🇿     | Uzbekistan                     | +998       | 00 000 0000       |
| 🇻🇺     | Vanuatu                        | +678       | 00 000            |
| 🇻🇦     | Vatican City                   | +39        | 000 000 000       |
| 🇻🇪     | Venezuela                      | +58        | 000 000 0000      |
| 🇻🇳     | Vietnam                        | +84        | 000 0000 000      |
| 🇾🇪     | Yemen                          | +967       | 00 000 000        |
| 🇿🇲     | Zambia                         | +260       | 00 000 0000       |
| 🇿🇼     | Zimbabwe                       | +263       | 00 000 0000       |



## Changelog

Refer to the [Changelog](https://github.com/ziqq/flutter_simple_country_picker/blob/master/CHANGELOG.md) to get all release notes.



## Maintainers

[Anton Ustinoff (ziqq)](https://github.com/ziqq)



## Funding

If you want to support the development of our library, there are several ways you can do it:

- [Buy me a coffee](https://www.buymeacoffee.com/ziqq)
- [Support on Patreon](https://www.patreon.com/ziqq)
- [Subscribe through Boosty](https://boosty.to/ziqq)



## License

[MIT](https://github.com/ziqq/flutter_simple_country_picker/blob/master/LICENSE)



## Coverage

<img src="https://codecov.io/gh/ziqq/flutter_simple_country_picker/graphs/sunburst.svg?token=fpn56ea0L8" width="375" />