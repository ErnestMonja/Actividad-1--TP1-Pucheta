% Trabajo Práctico N°1 - Pucheta.
% Resolución planteada por Ernesto Monja.

% ITEM N°2:
close all; clear all; history -c; clc;
pkg load control;
% pkg install -forge io
pkg load io;

% Como indica la consigna, se tiene que leer los archivos guardados en un archivos
% de Excel en formato .xls, al cual se paso a .xlsx para poder trabajarlo en
% Octave y se guardaron los datos de la tabla en las siguientes variables:
data = xlsread('Curvas_Medidas_RLC_2025.xlsx');
    t  = data(1:end, 1);         % Tiempo.
    I  = data(1:end, 2);         % Corriente en el circuito.
    Vc = data(1:end, 3);         % Caída de tensión en el capacitor.
    Ve = data(1:end, 3);         % Tensión de alimentación ( Ve(t) = u(t) ).
    Vr = data(1:end, 5);         % Caída de tensión en la resistencia, salida.

% Realizo los gráficos de las variables dadas en el archivo de excel para
% observar el comportamiento del sistema:
figure;
subplot(4,1,1);                  % Grafico la corriente I(t)
plot(t, I);
title('Corriente');
xlabel('Tiempo [s]');
ylabel('Corriente [A]');
grid on

subplot(4,1,2);                  % Grafico la tensión del capacitor Vc(t)
plot(t, Vc, 'red');
title('Caida de tensión en el capacitor');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

subplot(4,1,3);                   % Grafico la tensión de entrada Ve(t) = u(t)
plot(t, Ve, 'blue');
title('Tensión de entrada');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

subplot(4,1,4);                   % Grafico la caida de tensión en la resistencia
plot(t, Vr, 'green');             % Vr(t)
title('Caída de tensión en la resistencia');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

%   Vemos que se trata a un esquema similar al que muestra el enunciado de la
% consigna donde se nos pedira en base a la tensión del capacitor como salida,
% encontrar los parámetros R, L y C del circuito. Para ello se nos pide emplear
% el método de la respuesta al escalón, tomando como salida la tensión en el
% capacitor.
%   Primero es conveniente transformar la salida del sistema (tensión del
% capacitor) a una forma donde no se tenga el retardo propio de 0.01 [s] y que
% termine cuando se cambie la polaridad de la entrada Ve(t). Para ello se propone
% la siguiente linea de codigo:
delay = 0.01;
ind_util = find(t >= 0.01 & t <= 0.025);
t_util = t(ind_util) - delay;
Vc_util = Vc(ind_util);

% Grafico a Vc_util:
figure(2);
plot(t_util, Vc_util, 'red');
title('Caida de tensión en el capacitor (respuesta a una entrada de 12V)');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
grid on

%   Ya obtuvimos la salida del sistema, por lo tanto se tiene que existe una
% forma de obtener las constantes de tiempo T1 y T2 que definen a los polos del
% sistema y consecuentemente a los parámetros R, L y C del circuito, es mediante
% el método propuesto por Lei Chen. En este método se propone tomar 3 puntos
% equiespaciados de la salida del sistema ante una respuesta escalón.
%   El apartado 5 del artículo de Chen describe el caso general para obtener las
% constantes de tiempo de un sistema de 2do orden donde se tienen 1 cero y 2
% polos el cual es el caso de la función de transferencia de un circuito RLC
% es el de nuestro caso. Esta función es de la forma:

%   Vc             1/LC           Fórmula según            (T3*s + 1)
%  ---- = -------------------- = ---------------> = K ----------------------
%   Ve    s^2 + (R/L)*s + 1/LC        Chen             (T1*s + 1)(T2*s + 2)

%   Chen nos indica que debemos elegir 3 puntos igualmente espaciados para aplicar
% su algoritmo. Para ello y observando la tabla del Excel + gráficos, vemos que:
%      t = 0,0100 [s] ---> y(t) = Vc(t) = 0 [V]
%      t = 0,0130 [s] ---> y(t) = Vc(t) = 11,9759 [V]
%      t = 0,0193 [s] ---> y(t) = Vc(t) = 12 [V]
%      t = 0,0500 [s] ---> y(t) = Vc(t) = 12 [V]
%   Se observa que donde ocurre el transitorio de al función se da en el
% intervalo [0,1 ; 0,13] donde se tienen 300 valores según la tabla de excel de
% entremedio. Por lo tanto elegimos con un criterio razonable que:
t_1 = data(1023,1) - delay;
y_1 = data(1023,3);

t_2 = data(1045,1) - delay;
y_2 = data(1045,3);

t_3 = data(1067,1) - delay;
y_3 = data(1067,3);

%   Se selecciona un 4to punto de operación. Esto es debido a que el método de
% Chen solo funciona para y(inf) = 1, y para ello es conveniente elegir un punto
% justo donde la gráfica de Ve(t) cambie de +12 [V] a -12 [V], y este punto se
% encuentra en el valor t = 0,05 [s] tal que:
t_ss = data(5000,1) - delay
y_ss = data(5000,3)

%   Luego solo resta aplicar el algoritmo de Chen utilizando las siguientes
% fórmulas obtenidas de su artículo, tal que:
K = 1;
k1 = (y_1/y_ss) - 1;
k2 = (y_2/y_ss) - 1;
k3 = (y_3/y_ss) - 1;

b      = 4*(k1^3)*k3 - 3*(k1^2)*(k2^2) - 4*(k2^3) + k3^2 + 6*k1*k2*k3;
alpha1 = (k1*k2 + k3 - sqrt(b))/(2*(k1^2 + k2));
alpha2 = (k1*k2 + k3 + sqrt(b))/(2*(k1^2 + k2));
beta   = (k2 + alpha2^2)/(alpha1^2 - alpha2^2);

T1 = real((-t_1/log(alpha1)));
T2 = real((-t_1/log(alpha2)));
T3 = real((beta*(T1 - T2) + T1));

%   Dado que Chen propuso como calcular la Función de transferencia mediante las
% constante de tiempo T1, T2 y T3. Se propone ver como difiere la aproximación
% con la salida origial dada por Vc_util, tal que:
s = tf('s');
FdT_CHEN = K/((s*T1 + 1)*(s*T2 + 1))
FdT_CHEN_RESP = step(12*FdT_CHEN, t_util);

%   Comparamos la respuesta inferida con los valores de la tabla
figure(3);
plot(t_util, FdT_CHEN_RESP, 'green', t_util, Vc_util, 'red');
title('Caída de tensión en el capacitor');
xlabel('Tiempo [s]');
ylabel('Voltaje [V]');
legend('Respuesta obtenida por el método de Chen', 'Respuesta Original obtenida del Excel');
grid on;

%   Se observa un error entre ambas gráficas el cual es a fines prácticos, casi
% nulo, lo que es un buen indicio de que el valor de los puntos escogidos y su
% separación es correcta para aproximar y obtener la función de transferencia.
%   Con esta función en mente, podemos proceder a obtener los parámetros R, L y
% C del circuito planteado, donde:

%   Vc             1                                1
%  ---- = ----------------------  =  --------------------------------
%   Ve     (LC)s^2 + RC*s + 1         4.14e-09 s^2 + 0.0004903 s + 1

%   Comparando denominadores, se tiene que podemos resolver los parámetros del
% circuito. Nótese que el valor de la resistencia se puede inferir facilmente de
% acuerdo a los valores de la tabla ya que se tomaron mediciones de tensión sobre
% la resistencia y corriente de la malla, tal que si tomamos el valor en la
% posición, por ejemplo:
R = data(5001,5)/data(5001,2)            % R = 220 [Ω]

%   Comparando el segundo término de los denominadores podemos obtener el valor
% del capacitor como:
C = 0.0004903/R                          % C = 2,2286 [uF]

%   Por último, comparando el valor del primer termino de ambos denominadores,
% se tiene que:
L = 4.14e-09/C                           % L = 1,8576 [mHy]
