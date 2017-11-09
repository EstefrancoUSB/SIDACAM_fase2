function [Ruido_fondo, Hora_fondo] = Grabacion(tiempo,Frec_muestreo)

%GRABACIÓN
%------------------------------------------------------------------------------
% David Pérez Zapata / ing.davidpz@gmail.com
% Luis Esteban Gómez  / estebang90@gmail.com
% Luis Alberto Tafur Jiménez / decano.ingenierias@usbmed.edu.co
%
% Esta función se encarga de grabar el ruido de fondo para comparar posteriormente ésta señal
% con la señal de la embarcación. De esta manera aplicar la ecuación de sonar pasivo y
% determinar umbrales de detección.
%
%ENTRADAS
%tiempo            Double. tiempo durante el cual se grabará señal externa. [s]
%Frec_Muestreo  Double. frecuencia de muetreo de la señal: 48000. [Hz]
%SALIDAS
%Ruido_fondo       Double. Señal capturada por el receptor.
%Hora_fondo        String. Fecha y hora de la señal de ruido de fondo capturada.


n_bits = 16;      % Tamaño de la muestra en bits
n_canales = 1;    % Número de canal (mono)

%Grabación de la señal capturada desde el receptor.
recObj = audiorecorder(Frec_muestreo, n_bits, n_canales);
disp('Comienzo Grabación.')
recordblocking(recObj, tiempo);
disp('Fin Grabación.');
Ruido_fondo = getaudiodata(recObj);
Hora_fondo = datestr(now);