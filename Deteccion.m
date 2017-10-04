function [Embarcacion] = Deteccion(tiempo,Frec_Muestreo,Dim_fft, Frec_Corte1, N_Frec, Step)

%DETECCI�N
%------------------------------------------------------------------------------
% David P�rez Zapata / ing.davidpz@gmail.com
% Luis Esteban G�mez  / estebang90@gmail.com
% Luis Alberto Tafur Jim�nez / decano.ingenierias@usbmed.edu.co
%
% Esta funci�n se encarga de grabar la se�al de la embarcaci�n objetivo para extraer su 
% respectiva firma ac�stica y compararla con las dem�s firmas almacenadas en la base de datos.
% Da como resultado la embarcaci�n a la que m�s se asemeja la se�al capturada.


%Carga de variable a utilizar
Corr_vector = zeros(1,20);
load info_barcos

%Se llama a la funci�n "Grabacion" para captura de se�al.
[Captacion_Blanco, ~] = Grabacion(tiempo,Frec_Muestreo);

%Llamado de la funci�n "Banco_filtros" para extracci�n de m�ximos.
[Max_Bandas_dB,Frec_Max] = Banco_filtros (Captacion_Blanco,Frec_Muestreo, N_Frec,Dim_fft,...
    Frec_Corte1, Step);

%Parametrizaci�n de la firma ac�stica de la se�al capturada (objetivo a comparar).
maximo = max (Max_Bandas_dB);
Firma_Captura = 1./(Max_Bandas_dB/maximo);

%Comparaci�n de la firma ac�stica del objetivo con toda la base de datos.
for Comp_firmas = 1:length(info_barcos{1,1})
    [Correlacion,~] = xcorr(Firma_Captura,info_barcos{5,1}{Comp_firmas}(4,:),0,'coeff');
    Corr_vector(Comp_firmas) = Correlacion;
end
%Determinaci�n de cu�l correlaci�n dio mejor resultado para comparar y determinar la posible 
%lancha.
stem(Corr_vector)
[~,pos] = max(Corr_vector); 
Embarcacion = info_barcos{1,1}{pos};    








