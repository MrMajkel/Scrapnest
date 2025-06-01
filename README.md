## ScrapNest 

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Aplikacja internetowa zaprojektowana z myślą o firmach zajmujących się obrotem surowcami oraz materiałami. Umożliwia zarządzanie dokumentacją sprzedażową, zakupową i magazynową w jednym, wygodnym systemie online.

**Technologie użyte w projekcie:**
- HTML / CSS – struktura i stylowanie interfejsu użytkownika
- JavaScript – interaktywność i dynamiczne elementy aplikacji
- PHP – logika serwera i obsługa zapytań do bazy danych
- PostgreSQL – relacyjna baza danych przechowująca dane o fakturach, kontrahentach, surowcach i użytkownikach
- Docker – konteneryzacja aplikacji i uproszczone środowisko wdrożeniowe
- GitHub – kontrola wersji<br><br>

**Główne funkcjonalności:**
- Zarządzanie formularzami – tworzenie i edycja formularzy
- Dodawanie faktur sprzedażowych i zakupowych – ewidencja operacji handlowych
- Moduł kontrahentów – rejestrowanie i zarządzanie odbiorcami 
- Zarządzanie użytkownikami – tworzenie kont, nadawanie ról
- Podgląd stanu magazynowego – aktualny wgląd w ilość dostępnych surowców<br><br>

**Cel projektu:**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Celem ScrapNest jest ułatwienie codziennego zarządzania dokumentami oraz stanem magazynowym w firmach, które potrzebują szybkiego i prostego narzędzia do kontroli przepływu towarów i danych.


## Panel logowania:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Strona startowa aplikacji zawiera panel logowania podzielony na dwie sekcje. Po lewej stronie znajduje się grafika z logo aplikacji, natomiast po prawej stronie umieszczono formularz logowania. Aplikacja jest w pełni responsywna – widok mobilny automatycznie dostosowuje się do rozmiaru ekranu, aktywując „burger menu”.

![image](https://github.com/user-attachments/assets/ceb8b865-a097-4c93-9c7a-2b56e68d1b58)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/e50620fd-04c7-4b94-8089-4b8f9c1dcf7e)

## Panel rejestracji:
Panel rejestracji umożliwia użytkownikowi uzupełnienie danych takich jak: imię, nazwisko, adres e-mail, hasło oraz wybór roli.

![image](https://github.com/user-attachments/assets/3e2864ba-d4b3-4fa7-b5bc-01bbd93e7257)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/ea85ed11-38c9-4294-a8bb-57ec1e043671)

 ## Panel użytkownika

**Statystyki:**
- Łączna liczba metali – pokazuje, że w systemie znajduje się różne rodzaje metali.<br>
- Całkowita masa – aktualna całkowita masa wszystkich metali w magazynie.<br>
- Ilość odbiorców – liczba firm/osób (kontrahentów)<br>
- Ilość formularzy – liczba dokumentów zakupowych<br>

![image](https://github.com/user-attachments/assets/9c4f326b-b786-4666-8326-f4bb8eacbd08)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/aae1ee11-b32c-4599-af8f-aabebb5e73a7)

## Formularze

**Funkcjonalność:**
- Dodawanie formulaza („+Dodaj formularz”) - dodawanie formularza z ilością danych
- Edycja („Edytuj”) – możliwość modyfikacji danych w formularzu (np. korekta masy, metalu, daty)
- Usuwanie („Usuń”) – trwałe usunięcie formularza z systemu

![image](https://github.com/user-attachments/assets/43d608dd-669b-45ae-8516-0a27d991ad75)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/76a3add7-e448-4b21-8593-30882192ff1d)

## Faktury zakup

**Funkcjonalność:**
- Dodawanie faktury („+Dodaj fakturę”) - dodawanie faktury z ilością danych
- Edycja („Edytuj”) – możliwość modyfikacji danych w formularzu (np. korekta masy, metalu, daty)
- Usuwanie („Usuń”) – trwałe usunięcie formularza z systemu

![image](https://github.com/user-attachments/assets/3808b7a0-84dc-4d28-8d74-ebef085ffe91)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/a3d88792-4020-42c7-9c86-0f0fcb94b521)

## Faktury sprzedaż

**Funkcjonalność:**
- Dodawanie faktury („+Dodaj fakturę”) - dodawanie faktury z ilością danych
- Edycja („Edytuj”) – możliwość modyfikacji danych w formularzu (np. korekta masy, metalu, daty)
- Usuwanie („Usuń”) – trwałe usunięcie formularza z systemu

![image](https://github.com/user-attachments/assets/734aa58e-ee15-410f-b99b-94b14ebd7862)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/32fb278d-58f5-4b09-9451-9c807513dec8)

## Kontrahenci

**Funkcjonalność:**
- Dodawanie faktury („+Dodaj kontrahenta”) - dodawanie kontrahenta
- Edycja („Edytuj”) – możliwość modyfikacji danych kontrahenta (nazwa firmy, BDO, NIP, Adres, Telefon, e-mail)
- Usuwanie („Usuń”) – trwałe usunięcie kontrahenta z systemu

![image](https://github.com/user-attachments/assets/53839744-72db-4000-9e70-530a47a17a0e)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/bf7f31a7-2494-462e-945d-edc45736cc3f)

## Raporty

**Dostępne akcje:**
- Przycisk „Drukuj” – umożliwia bezpośrednie wydrukowanie raportu.
- Przycisk „Excel (CSV)” – umożliwia eksport danych do pliku CSV (czyli w formacie zgodnym z Excel), co pozwala na dalszą analizę, archiwizację lub przesyłanie danych.

![image](https://github.com/user-attachments/assets/63b72dfb-de45-4216-8edd-5393f055f1b7)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/3e9b77b6-568d-4033-bdf9-15cf6546b4d4)

## Użytkownicy (dostępni tylko z poziomu administratora)

**Funkcjonalność:**
- Dodawanie użytkownika („+Dodaj użytkownika”) - dodawanie uzytkownika
- Edycja („Edytuj”) – możliwość modyfikacji danych w użytkownika (imię, nazwisko, e-mail, hasło, rola)
- Usuwanie („Usuń”) – trwałe usunięcie użytkownika z systemu

![image](https://github.com/user-attachments/assets/c9c7881e-09b4-454f-8270-04f8e0f0513f)

**Wersja mobilna:**

![image](https://github.com/user-attachments/assets/067d9c38-9d54-46a9-b79a-5a3d60cc56c5)

## Hamburger menu

![image](https://github.com/user-attachments/assets/31d2984e-7c69-47dd-9f9b-fbe8df3c690c)

## Diagram ERD

![ERD](https://github.com/user-attachments/assets/879c3391-5111-406f-9ad7-32ed3fbc0cfc)
