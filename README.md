Watermark Benchmark - instrukcja obsługi;
Autor dokumentu - inż. Maciej Posłuszny.



Niniejsza instrukcja dotyczy obsługi środowiska Watermark stworzonego przez Norweski Instytut Badań 
Obronnych (Forsvarets forskningsinstitutt (FFI)). Środowisko to zostało stworzone z myślą o modelowaniu zjawisk
akustycznych w wodzie. Symulator ten wykorzystuje zweryfikowany przez FFI symulator MIME,
opierający się na pomiarach zmiennej w czasie odpowiedzi impulsowej, dokonanych w trakcie testów morskich.
Watermark został zaprogramowany w środowisku MATLAB i może być używany w systemach operacyjnych Windows lub Linux.



1. Dane o kanałach 

Watermark zawiera dane pomiarowe z 5 rzeczywistych kanałów o następujących właściwościach:
    1., 2. NOF1 (Norway – Oslofjord) oraz NCS1 (Norway — Continental Shelf):
	=> pojedynczy hydrofon (SISO);
	=> zakres częstotliwości: 10-18 kHz;
	=> 60 nagrań po 33 sekundy każdy. 
    3. BCH1 (Brest Commercial Harbour):
	=> VLA (Vertical Line Array) składający się z 4 hydrofonów (SIMO);
	=> zakres częśtotliwości: 32.5-37.5 kHz;
	=> 4 nagrania po 1 minutę każdy. 
    4., 5. KAU1 oraz KAU2 (Kauai 1/Kauai 2):
	=> VLA zawierający 16 hydrofonów (SIMO);
	=> zakres częstotliwości 4-8 kHz;
	=> 1 nagranie trwające 33 sekundy.
Dla każdego z podanych kanałów pasmo częstotliwości jest pasmem o spadku o -3dB sygnału sondującego.
Warto odnotować, że kanały nie muszą być kanałami stacjonarnymi!

Każdy z powyższych kanałów zaopatrzony jest w wykresy przedstawiające:
    1. Odpowiedź impulsową kanału h(t, τ);
    2. Funkcję rozpraszania S(υ, τ) - rozkład energii sygnału w czasie jego propagacji;
    3. Widmo zjawiska Dopplera;
    4. Fazę szczątkową sygnału;
    5. Profil opóźnienia mocy sygnału;
    6. Funkcję autokorealcji - szybkość zmian kanału.

Kanały testowe znajdują się w ścieżce \Watermark\input\channels w folderze odpowiadającym danemu kanałowi.
Folder \mat zawiera pliki .mat z danymi dotyczących propoagacji fali akustycznej. W przypadku kanałów
NOF1, NCS1 i BCH1 pliki numerowano są zgodnie z kolejnością plików dźwięków, w przypadku KAU1, KAU2 zaś
numery odpowiadają numerom zastosowanych hydrofonów.


2. Struktura plików

Każdy z plików .mat zawiera następujące dane:
    => V_0 - średnia wartość przesunięcia Dopplera [m/s];
    => f_c - częstotliwość środkowa sygnału sondującego [Hz];
    => f_{s, t} - częstotliwość próbkowania w dziedzinie czasu [Hz] dla funkcji h(t, τ);
    => f_{s, τ} - częstotliwość próbkowania w dziedzinie opóźnienia [Hz] dla funkcji h(t, τ);
    => h = h(t, τ);
    => meta - struktura danych zawierająca dodatkowe informacje. Jest to struktura nieużywana w programie,
	zawiera ona wyłącznie dane zadane przez twórcę pliku .mat.
Główna funkcja Watermark przetwarzanie danych rozpoczyna od próbki oznaczonej numerem _001 i zakłada, że
pozostałe pliki zawierają identyczne parametry.

Rolą użytkownika oprogramowania jest utworzenie skryptu, który tworzy plik .mat znajdujący się w katalogu
\Watermark\input\signals. W przypadku uteorzenia sygnału o różnej przepływności danych (eng. data rate) lub 
wielu zakresów częstotliwości plików .mat winno się znajdować odpowiednio więcej.

Zadany plik .mat zawierać musi 3, i tylko 3, ściśle określone parametry sygnału:
    1. f_{s,x} - częstotliwość próbkowania sygnału [Hz];
    2. nBits - Liczba bitów;
    3. x = x(t) - sygnał, będący wektorem danych (Rozmiar {nBits}x1).
Należy unikać niepotrzebnych próbek przed początkiem lub na końcu sygnału - np. tzw. zer w ogonie
(eng. trailing zeros, ponieważ takie próbki obniżają efektywną przepływność bitową oraz zmniejszają
liczbę pakietów w symulacji.
Warto również nie używać zbyt wysokich częstotliwości próbkowania, gdyż pakiety wyjściowe
są zapisywane i zwracane z tą samą częstotliwością, co sygnał wejściowy. Nadpróbkowanie powoduje
jedynie wydłużenie czasu obliczeń i zwiększenie zużycia miejsca na dysku.

Program Watermark działa WYŁĄCZNIE W PROGRAMIE MATLAB w systemie operacyjnym Windows i Linux.
Wymaga on wersji Matlaba R2012b lub nowszej oraz zainstalowanego pakietu Signal Processing Toolbox.
W katalogu \Watermark\matlab\ znaleźć można niezbędne funkcje.



3. Operowanie programu

Po utworzeniu dedykawonego sygnału należy przepuścić go funkcję Watermark.m. Jest to funkcja
przyjmująca następujące argumenty:
    1. signal - nazwa sygnału wyrażona jako string;
    2. channel - nazwa wykorzystywanego kanału, wyrażona jako string;
    3. howmany - przyjmuje wartości 'all' lub 'single' w zależności ile plików chcemy przetworzyć.
Funkcja ta przyjmuje sygnał wejściowy, nakłada na siebie wiele jego kopii oraz przepuszcza je
przez kanały transmisyjne. Te ostatnie zawarte są w funkcji replayfilter.m, do którego odwołuje się
funkcja watermark.m i nie powinna być używana oddzielnie przez użytkownika.

Przykładowe dane wyjścowe funkcji watermark.m mogą wyglądać następująco:
"
    >>watermark('ofdm', 'BCH1', 'all');
    
    Watermark V1.0
    -------------
    Signal parameters for ofdm:
    message size = 2800 user bits
    total duration = 3.466 s
    effective bit rate = 807.83 bit/s

    Channel parameters for BCH1:
    center frequency = 35000 Hz
    sounding duration = 59.4 s
    number of soundings = 4

    Number of packets per sounding = 16
    Total number of simulated packets = 64

    Deleting previous results, if any ... done.

    Filtering ofdm x BCH1_001 ... done.
    Filtering ofdm x BCH1_002 ... done.
    Filtering ofdm x BCH1_003 ... done.
    Filtering ofdm x BCH1_004 ... done.
    >>
"
W wyniku działania tej funkcji w katalago output znajduje się odpowiednia liczba nagrań (zgodna
z wybranym kanałem) oraz plik bookkeeping.mat zawierający strukturę danych 'bk' z informacjami
pomocniczymi. Liczba indywidualnych plików danych zależy od czasu trwania sygnału, czasu nagrania
związanego z wyborem kanału oraz liczby parametrów sygnału.

Dla szybkiego przeprowadzenia testu, czy funkcja "działa" można wprowadzić wartość zmiennej howmany
jako 'single' co ogranicza output niemniej jest on bezwartościowy z punktu widzenia obróbki danych,
gdyż do tego potrzebne są dane z wszystkich plików.

Gdy sygnał został już przepuszczony przez odpowiedni kanał, wyjściowe pakiety danych mogą zostać
pobrane za pomocą funkcji sfetch.m lub pfetch.m.
    1. sfetch.m (serial fetch) - pobiera dane uzyskane z kanału operującego na pojedynczym hydrofonie (SISO),
	a zatem z NOF1 i NCS1;
    2. pfetch.m (parallel fetch) - pobiera dane uzyskane na macierzy mikrofonów (SIMO), a zatem z kanałów BCH1,
	KAU1 oraz KAU2.

Funkcja sfetch.m przyjmuje następujące argumenty:
    1, 2. signal oraz channel - analogicznie dla funkcji watermark;
    3. packetNumber - numer pakietu mieszczący się w przedziale (1, N_max), gdzie N_max -
	sumaryczna liczba pakietów;
    4. SNR - ewentualny argument, który dodaje szum biały gaussowski o parametrze SNR (Signal 
	to Noise Ratio) równym 30dB (E_b/N_0, gdzie E_b - energia sygnału dla pojedynczego bitu danych,
	a N_0 - gęstośc widmowa mocy PSD (Power Spectral Density)).

Argumentu SNR warto używać, ponieważ detekcja i synchronizacja są kluczowymi zadaniami modemów i schematów modulacji.
Watermark ma na celu umożliwienie realistycznego porównania autonomicznych odbiorników. Niemniej użycie go
wiąże się z wydłużeniem sygnału o ok. 10s, co powoduje losowe opóźnienie po 4-6 sekundach.

Charakterystyka szumu tła w oceanach bardzo różni się w zależności od środowiska i warunków. W regionach, gdzie szum
jest zdominowany przez wzburzenie powierzchni morza, mogą występować statystyki Gaussowskie, ale zazwyczaj szum jest 
"kolorowy” (tzn. ma różne widmo mocy w zależności od częstotliwości). Powód użycia AWGN (Additive White Gaussian Noise)
w Watermark jest taki, że pozwala to na stosowanie jednoznacznej metryki Eb/N0 do określenia SNR. Alternatywnie, 
użytkownicy mogą pobierać pakiety bez szumu i stosować różne modele szumu lub zmierzone szumy, jeśli są one dostępne.

Funkcję serial fetch można zastosować do danych z macierzy hydrofonów, ale zwraca ona pojedynczy sygnał. Pakiet 1 to
pierwszy pakiet odebrany na pierwszym hydrofonie, a ostatni dostępny pakiet to ostatnia transmisja odebrana na ostatnim hydrofonie.

Przykładowe użycie funkcji sfetch.m:
"
    » [y, fs] = sfetch(’dsss4’, ’NOF1’, 1, 30);
"

Funkcja pfetch.m ma niemal identyczne działanie co sfetch.m z jednym zastrzeżeniem - brak jest parametru SNR, ponieważ
pierwsza wersja Watermarka nie posiada modelu zawierającego szum o realistycznych wałściwościach przestrzennych.
Autorzy programu rekomendują dodanie szumu przez użytkownika.

Przykładowe użycie funkcji pfetch.m:
"
   » [y, fs] = pfetch(’ofdm’, ’BCH1’, 1);
"
Jeżeli funkcja 'parallel fetch' zostanie zastosowana do kanałów niebędących macierzami, np. 'NOF1' wówczas zwrócona zostanie
macierz o 60 kolumnach, odpowiadająca odbiorowi pierwszego pakietu w każdej z 60 transmisji.



4. Raportowanie wyników

Niestety brak jest standardowych procedur dotyczących raportowania danych w akustyce podwodnej, co może powodować wszelkie
konfuzje związanych z podstawową terminologią. Autorzy oporgramowania rekomendują, żeby w potencjalnym raporcie dotyczącym
użycia programu znalazły się następujące elementy:
    => wersja Watermarka;
    => liczba bitów sygnału (nBits);
    => liczba bitów na sekundę (effective bit rate);
    => przedział częstotliwości (bandwidth);
    => sumaryczna liczba pakietów danych;
    => użyty rodzaj szumu w symulacji (dla 'serial fetch' domyślnym szumem jest AWGN - Additive White Gaussian Noise);
    => informacja, czy wyniki są uśrednione względem wszystkich pakietów czy konkretnych danych;
    => definicje przedziału częstotliwości (bandwidth) wejściowego SNR i wyjściowego SNR zadane przez użytkownika;
    => czy wykorzystywana jest wcześniejsza wiedza o początku sygnału lub przesunięciu Dopplera, czy też odbiornik
	 musi sam to ustalić (np. za pomocą detektora preambuły z bankiem Dopplerowskim);
    => w jakim stopniu parametry sygnału i odbiornika są dostosowane do badanego kanału;
    => wszelkie inne informacje, które pomagają odtworzyć wyniki lub zrozumieć ich znaczenie.

Przykłady zastosowanych modulacji przez autorów oprogramowania to DSSS (Direct Sequence Spread Spectrum) i QPSK
(Quadrature Phase-Shift Keying) używane dla 'serial fetch'. Dla 'parallel fetch' stosowana jest metoda OFDM
(Orthogonal Frequency-Division Multiplexing). Oczywiście użytkownik może użyć innych modulacji wedle życzenia,
niemniej należy robić to z rozwagą!



5. Podsumowanie

Dzięki istnieniu Watermarka dostępne jest teraz rzetelne oprogramowanie (benchmark) dla systemów podwodnej komunikacji akustycznej.
Opiera się ono na symulatorze kanału odtwarzanego (replay channel simulator), który działa w oparciu o rzeczywiste pomiary zmiennej
w czasie odpowiedzi impulsowej kanału. Początkowa biblioteka obejmuje pięć kanałów testowych, reprezentujących cztery różne obszary 
geograficzne i trzy pasma częstotliwości. Dwa z tych kanałów oferują odbiór za pomocą pionowej linii hydrofonów (vertical line array).
Głównym przeznaczeniem środowiska Watermark jest testowanie i porównywanie warstwy fizycznej systemów komunikacji akustycznej.
W zasadzie jednak może ono zostać wykorzystane również w innych zastosowaniach sonarowych, obejmujących jednokierunkową transmisję dźwięku.

Watermark umożliwia wniesienie realizmu pomiarów morskich do biura, zachowując przy tym pełną powtarzalność eksperymentów.
Typowe zastosowania obejmują:
    => opracowanie, testowanie i udoskonalanie algorytmów;
    => dokumentowanie wydajności różnych schematów modulacji i ustawień parametrów - zarówno do użytku wewnętrznego, jak i w publikacjach
	naukowych;
    => porównywanie różnych metod modulacji w tym samym kanale;
    => analizę działania wybranego schematu w różnych kanałach;
    => poszukiwanie odpornego systemu o wysokiej przepływności danych;
    => ekstrakcję statystyk błędów do symulacji sieciowych;
    => badanie właściwości kanału akustycznego;

Benchmark ten może być rozszerzany o kanały pochodzące z innych środowisk i pasm częstotliwości — zarówno do użytku własnego,
jak i do ogólnej dystrybucji, w zależności od gotowości innych instytucji do przeprowadzenia odpowiednich pomiarów i udostępnienia danych.



Komentarz od autora instrukcji:
w udostępnionych plikach można znaleźć oficjalną instrukcję opublikowaną przez FFI oraz skrypt w rozszerzeniu .mlx, stworzony przez autora
instrukcji, który tworzy sygnał OFDM do analizy w Watermarku. Skrypt może stanowić punkt odniesienia do dalszych skryptów stworzonych przez
użytkownika. Inne materiały (być może) będą konsekwentnie dodawane.

