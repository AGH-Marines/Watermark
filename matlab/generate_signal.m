clc
clear

% Zapisanie wygenerowanego sygnału do pliku .mat
lokalizacja = "C:\...\my_signal.mat";
m = matfile(lokalizacja, "Writable", true);

%% 1. Zdefiniowanie sygnału
% Ustawienie kanału
channel = 'BCH1';  % Options: 'NOF1', 'NCS1', 'BCH1', 'KAU1', 'KAU2'

% Zdefiniowanie pasma częstotliwości i odpowiedniej częstotliwości próbkowania fs_x
switch channel
    case {'NOF1', 'NCS1'}
        f_min = 10000; 
        f_max = 18000;
        fs_x  = 40000;  % *1
    case 'BCH1'
        f_min = 32500; 
        f_max = 37500;
        fs_x  = 80000;  % krok 600 Hz dla 128 podnośnych 
    case {'KAU1', 'KAU2'}
        f_min = 4000; 
        f_max = 8000;
        fs_x  = 20000;  % Lub 16 kHz
    otherwise
        error('Invalid channel selected');
end

% Pozostałe parametry
N = 128;                % Liczba podnośnych OFDM (każda przenosi część wiadomości) *2
cp_len = N/4;           % Długość prefiksu cyklicznego (dodaje redundancję w celu przeciwdziałania echu/wielodrożności w wodzie) *3

% Czas trwania sygnału (dostosuj w razie potrzeby)
T = 5;

% Wektor czasu
t = (0:1/fs_x:T-1/fs_x);

%% 2. Modulacja i parametry sygnału
% Wybór modulacji
modulation = 'QPSK';    % Wybierz: 'BPSK', 'QPSK' lub '16-AM' *4

% Liczba bitów na symbol
switch modulation
    case {'BPSK'}
        M = 2;      % 1 bit na symbol (bardzo odpornana zakłócenia, kosztem niskiej przepływności danych)
    case {'QPSK'}
        M = 4;      % 2 bity na symbol (równowaga między przepływnością i odpornością)
    case '16-AM'
        M = 16;     % 4 bity pna symbol (większa przepływność, ale mniejsza odporność)
    otherwise
        error('Invalid modulation selected');
end

% Obliczanie liczby bitów (nBits)
bps = N*log2(M);        % Liczba bitów na symbol OFDM                                               
symbol_rate = fs_x/N;   % Liczba symboli na sekundę

% Całkowita liczba bitów w czasie T sekund (z uwzględnieniem prefiksu cyklicznego)
nBits = T*(symbol_rate*bps*N/(N + cp_len));

%% 3. Generowanie strumienia bitów
% Generowanie bitów danych
data_bits = randi([0 1], nBits, 1);             % Losowy ciąg bitów (symuluje rzeczywiste dane)

% Weryfikacja czy liczba bitów pasuje dokładnie do liczby symboli
num_symbols = floor(nBits/log2(M));             % Całkowita liczba symboli
data_bits = data_bits(1:num_symbols*log2(M));   % Przycinanie nadmiarowych bitów, w razie konieczności

% Przekształcenie na porcje odpowiadające jednemu symbolowi
data_symbols = reshape(data_bits, [], log2(M)); % Przekształcenie do formy odpowiedniej do modulacji

%% 4. Modulacja
% Zaaplikowanie modulacji
switch M % *5
    case 2 % **BPSK**
        modulated_symbols = 2*data_symbols - 1;
    case 4  % **QPSK**
        modulated_symbols = (2*data_symbols(:,1) - 1) + ...
                            1j*(2*data_symbols(:,2) - 1);    
    case 16  % **16-QAM**
        decimal_values = bi2de(data_symbols);  % Zamiana bitów na liczby dziesiętne
        modulated_symbols = qammod(decimal_values, 16, 'UnitAveragePower', true);
    otherwise
        error('Unsupported modulation scheme');
end

% Weryfikacja czy długość jest podzielna przez N (liczbę podnośnych)
num_symbols_adjusted = floor(length(modulated_symbols)/N)*N;            % Dopasowanie długości do wielokrotności N
modulated_symbols_adjusted = modulated_symbols(1:num_symbols_adjusted); % Przycięcie nadmiarowych symboli w razie potrzeby

%% 5. Konstrukcja sygnału OFDM %*6
% Przekształcenie zmodulowanych symboli do ramki OFDM (N podnośnych na symbol)
ofdm_frame = reshape(modulated_symbols_adjusted, N, []);   % Automatyczne dopasowanie liczby symboli

% Zastosowanie odwrotnej transformacji Fouriera (IFFT) na każdej kolumnie ramki OFDM
ofdm_time_domain = ifft(ofdm_frame, N, 1);  % IFFT wzdłuż kolumn

% Dodanie prefiksu cyklicznego (CP)
ofdm_time_domain_cp = [ofdm_time_domain(end-cp_len+1:end, :); ofdm_time_domain];

% Przekształcenie symbolu w dziedzinie czasu do pojedynczego wektora sygnału x
x = reshape(ofdm_time_domain_cp, [], 1)';  % Konwersja do pojedynczego wektora (wiersza)

%% 6. Eksport sygnału
% Zapis do pliku .mat
m.x = x;
m.fs_x = fs_x;
m.nBits = nBits;  

disp(['Selected channel: ', channel]);
disp(['Selected sampling rate: ', num2str(fs_x), ' Hz']);
disp(['Selected number of information bits: ', num2str(nBits)]);
disp(['Length of the signal x: ', num2str(length(x))]);

%% Sprawdzenie poprawności działania skryptu ✅
% Zakomentować, jeśli niepotrzebne
disp(['Channel: ', channel]);
disp(['Sampling Rate: ', num2str(fs_x), ' Hz']);
disp(['Modulation: ', modulation]);
disp(['Total Bits: ', num2str(nBits)]);
disp(['OFDM Symbols: ', num2str(num_symbols)]);
disp(['Length of the signal x: ', num2str(length(x))]);
disp('OFDM data symbols generated successfully!');

%% Treści dodatkowe
% Zakomentować, jeśli niepotrzebne

% Przebieg sygnału w czasie
figure;
plot(t(1001:2000), real(x(1001:2000))); % Część rzeczywista sygnału
title('Fragment sygnału OFDM w dziedzinie czasu');
xlabel('Czas [s]');
ylabel('Amplituda [m]');
grid on

n = length(x);
y = abs(fft(x)/(n/2));
f = fs_x*(0:n/2-1)/n;
y = y(1:n/2);
x = x(:);

% Widmo amplitudowo-częstotliwościowe
figure;
plot(f, real(y));
title('Widmo amplitudowo-częstotliwościowe sygnału OFDM');
xlabel('Częstotliwość [Hz]');
ylabel('Amplituda [m]');
grid on;

%% Komentarze
% *1 - dla 40kHz krok częstotliwościowy podnośnych (dla przyjętych 128
%       podnośnych) wynosi 312,5Hz. Dla 38,4kHz krok ten wynosi 300Hz.
% *2 - N = 2^7 = 128 zmniejsza odstęp między podnośnymi, co redukuje ISI (Inter-Symbol Interference),
%       ale zwiększa wrażliwość na efekt Dopplera.
% *3 - Cp_len = N/4 zapewnia dobrą ochronę przed wielodrożnością w akustyce podwodnej.
% *4 - Niestety modulacja BFSK stoi w sprzeczności z metodą BPSK;
%       Obecnie celujemy w modulację BPSK.
% *5 - BPSK: mapuje 0 → -1 i 1 → +1
%       QPSK: pary bitów są mapowane na wartości zespolone (składowa I i Q)
%       16-QAM: grupy po 4 bity są mapowane na konstelację punktów
% *6 - D-OFDM – dobrze radzi sobie z efektem Dopplera, co czyni go użytecznym
%       w pojazdach mobilnych, takich jak AUV (autonomiczne pojazdy podwodne).