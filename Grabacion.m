   function [Ruido_fondo, Hora_fondo] = Grabacion(tiempo,Frec_muestreo)

%GRABACI�N
%------------------------------------------------------------------------------
% David P�rez Zapata / ing.davidpz@gmail.com
% Luis Esteban G�mez  / estebang90@gmail.com
% Luis Alberto Tafur Jim�nez / decano.ingenierias@usbmed.edu.co
%
% Esta funci�n se encarga de grabar el ruido de fondo para comparar posteriormente �sta se�al
% con la se�al de la embarcaci�n. De esta manera aplicar la ecuaci�n de sonar pasivo y
% determinar umbrales de detecci�n.
%
% ENTRADAS
% n_bits                    Double. Profunidad en bits de la grabaci�n. [bits]
% n_canales                 Double. N�mero de canales de la grabaci�n.
% SALIDAS
% Ruido_fondo               Double. Se�al capturada por el receptor.
% Hora_fondo                Double. Fecha y hora de la se�al de ruido de fondo capturada.


n_bits = 16;      % Tama�o de la muestra en bits
n_canales = 1;    % N�mero de canal (mono)

%Grabaci�n de la se�al capturada desde el receptor.
recObj = audiorecorder(Frec_muestreo, n_bits, n_canales);
disp('Comienzo Grabaci�n.')
recordblocking(recObj, tiempo);
disp('Fin Grabaci�n.');
Ruido_fondo = getaudiodata(recObj);
Hora_fondo = datestr(now);