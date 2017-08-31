function  Firma_acustica (posicion,N_Frec)
%FIRMA ACUSTICA
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
% Función encargada de extraer la firma acústica de la señal promediando todos los máximos
% por frecuencia de todos los recorridos de cada embarcación previamente almacenados en
% Databse. En esta sesión se parametriza la firma acústica y se almacena en la base de datos.


load info_barcos
Promedio_maximos = zeros(1,35);
Promedio_frec = zeros(1,35);

for Cont_Maximos = 1:N_Frec
    sumatoria = sum (info_barcos{2,1}{posicion}(1,Cont_Maximos,:));
    Promedio_maximos(Cont_Maximos) = sumatoria/(info_barcos{3,1}(posicion));
    info_barcos{5,1}{posicion}(1,Cont_Maximos) = Promedio_maximos(Cont_Maximos);
    
    sumatoria = sum (info_barcos{2,1}{posicion}(2,Cont_Maximos,:));
    Promedio_frec(Cont_Maximos) = sumatoria/(info_barcos{3,1}(posicion));
    info_barcos{5,1}{posicion}(2,Cont_Maximos) = Promedio_frec(Cont_Maximos);
    info_barcos{5,1}{posicion}(3,Cont_Maximos) = std(info_barcos{2,1}{posicion}...
        (2,Cont_Maximos,1:(info_barcos{3,1}(posicion))))/Promedio_frec(Cont_Maximos);
    
end

Promedio = sum(Promedio_maximos)/N_Frec;
Comparacion_Prom = Promedio_maximos/Promedio;
Firma = 1./(Comparacion_Prom).^100;
info_barcos{5,1}{posicion}(4,1:35) = Firma;

save ('info_barcos','info_barcos')

% *******************************************************
% *** por favor fijarse en los comentarios del commit ***


