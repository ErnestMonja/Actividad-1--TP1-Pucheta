% Trabajo Práctico N°1 - Pucheta.
% Resolución planteada por Ernesto Monja.

% ITEM N°1:
close all; clear all; history -c; clc;
pkg load control;
pkg load signal;

% Inicializo las variables dadas como dato por el enunciado:
r = 220;                                   % Resistencia en [Ω].
l = 500*10^(-3);                           % Inductancia en [Hy].
c = 2.2*10^(-6);                           % Capacitancia en [F].

% Armo las matrices correspondientes a este sistema:
A = [-r/l, -1/l; 1/c, 0];                  % Matriz de Estados.
B = [1/l; 0];                              % Matriz de Entrada.
C = [r, 0];                                % Matriz de Salida.
D = [0];                                   % Matriz de Transmición Directa.

% Se procede a obtener la función de transferencia del sistema de acuerdo a las
% matrices obtenidas en el apartado anterior, mediante los siguientes comandos:
[num, den] = ss2tf(A, B, C, D);
G = tf(num, den)

% Se observa que se trata de un sistema de 2do orden por lo que se verificará
% cual es el polo dominante de la función:
polos = pole(G)
modulo_polos = abs(real(polos));
polo_dom     = min(modulo_polos)
polo_nod_dom = max(modulo_polos)

% Se observan 2 polos complejos conjugados de valores: -220 +- j(927,73). Se
% elije como tiempo de muestreo t_r al que responda a las dinámicas mas rápidas
% del sistema, para ello el modulo del polo mas cercano al origen de la función
% G(s), en este caso es indiferente tomar un polo o el otro y por lo tanto se
% tiene que:
t_r = -log(0.95)/(abs(polo_nod_dom))       % t_r = 2,3315 x 10^(-4) [s]
t_d = abs((2*pi/imag(min(polos)))/100)     % t_d = 6,7726 x 10^(-5) [s]

% Tomo el menor valor entre t_d y (t_r)/3
t_mues = min(t_r/3, t_d)                   % t_mues = 6,7726 x 10^(-5) [s]

% Luego el tiempo de simulación t_l se toma en base al polo más lejano al orígen
% y por lo tanto, este tiempo es igual a:
t_l = -log(0.05)/(abs(polo_dom))           % t_l = 0,013617 [s]

% Se toma aun asi el siguiente tiempo de simulación de acuerdo a la consigna:
t_sim = 0.2                                % t_sim = 0,2 [s]

% Resulta entonces que la cantidad de puntos que tendra nuestra simulación será
% igual a:
punt_tot = t_sim/t_mues                    % punt_tot = 2953,1 [puntos]

% Inicializo un vector de n numeros  equiespaciados linealmente entre un valor
% inicial y un valor final especificados, mediante el comando linspace() tal que:
% para un tiempo de simulación de 10ms y una entrada de 0V:
t = linspace(0, t_sim, punt_tot);
u = linspace(0, 0, punt_tot);

% Definimos a la entrada de acuerdo a la consigna, esto es una entrada escalon
% de 12V que cambia cada 10ms de signo luego de haber transcurrido unos 0.01 ms,
% tal que:
u(t > 0.01) = 12*(-1).^(floor((t(t > 0.01) - 0.01)/0.01));

% Esta función u(t>0.01) esta compuesta por una serie que alterna en valores
% negativos con valores positivos gracias al termino (-1)^n donde n se define
% en base a la función floor.

% Una vez obtenidos los parámetros para la simulación, tendremos que elegir las
% condiciones iniciales del sistema, donde se tendrá que el capacitor no tiene
% una tensión inicial tanto como el inductor no tiene una corriente inicial.
% Además se propone que la salida tampoco contará con un valor inicial, tal que:
I(1)  = 0;
Vc(1) = 0;
Vr(1) = 0;
x = [I(1) Vc(1)]';
x0 = [0 0]';                               % Punto de operación

% Inicializamos la simulación y calculamos los valores de las variables para
% cada punto:
for i = 1:(punt_tot-1);
    x_punto = A*(x - x0) + B*u(i);
    x = x + x_punto*t_mues;
    y = C*x;

    % Actualizo las salidas y demás variables de estado para la próxima
    % iteración:
    Vr(i+1) = y(1);
    I(i+1)  = x(1);
    Vc(i+1) = x(2);
end

% Finalmente grafico la entrada, salida y variables de estado
figure;

% Grafico la corriente I(t)
subplot(4,1,1);
plot(t, I);
title('Corriente');
xlabel('Tiempo [s]');
ylabel('Corriente [A]');
grid on

% Grafico la tensión del capacitor Vc(t)
subplot(4,1,2);
plot(t, Vc, 'red');
title('Caida de tensión en el capacitor');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

% Grafico la tensión de entrada Ve(t) = u(t)
subplot(4,1,3);
plot(t, u, 'blue');
title('Tensión de entrada');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

% Grafico la caida de tensión en la resistencia Vr(t)
subplot(4,1,4);
plot(t, Vr, 'green');
title('Caída de tensión en la resistencia');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on
