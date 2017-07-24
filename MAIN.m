%Este script contendrá el código principal del algoritmo de detección de
%barcos.

%% Creación base de datos.

% codigo_barco = cell(1,20);
% max_y_frec = cell(1,20);
% N_grabaciones = zeros(1,20);
% frec_principales = cell(1,20);
% info_barcos = {codigo_barco; max_y_frec; N_grabaciones; frec_principales};
% 
%  cambiar = cellfun('isempty',info_barcos{1,1});
%             info_barcos{1,1}(cambiar) = {'0'};
%             
% save('info_barcos')

%% inicialización de variables
Dim_fft = 4096;     %Minima longitud de ventana para optima resolucion en FFT.
Frec_Corte1 = 300;  %Frecuencia mínima de interés.
N_Frec = 35;        %Número de frecuencias para determinas firma acústica.
load info_barcos

condicion = 1;

while condicion == 1
    
    modo = menu('Escoja la modalidad de funcionamiento del programa.',...
        'Grabacion ruido de fondo.', 'Extracción firma acústica.', 'Detección de blancos.'...
        ,'SALIR.');
    
    switch modo
        
        case 1
            tiempo = input('Digite cuánto tiempo (en segundos) desea grabar ruido de fondo: ');
            Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal: ');
            [Ruido_fondo, Hora_fondo] = Grabacion(tiempo,Frec_Muestreo);
            
        case 2
            Codigo = input('Ingrese nombre o código de la embarcación: ', 's');
                                
            buscar = find(strcmp(info_barcos{1,1}, Codigo));
            if buscar ~= 0
                Mensaje = ['El barco ya existe en la posición ', num2str(buscar)];
                disp(Mensaje)
            else
                info_barcos{1,1}{min(find(strcmp(info_barcos{1,1}, '0')))} = Codigo;
            end
            
            Codigo(length(Codigo)+1:length(Codigo)+4) = '.wav';
            [S_Blanco, Frec_Muestreo] = audioread(Codigo);
            [Max_Bandas_dB, Frec_Max,Frecuencias] = Firma_acustica(S_Blanco,Frec_Muestreo,...
                Dim_fft, Frec_Corte1, N_Frec);
            info_barcos{2,1}{buscar} = [Max_Bandas_dB;Frec_Max];
            save('info_barcos')
        
        case 3
            [arg_salida3] = Deteccion(argumen_entrada3);
            
        case 4
            condicion = 2;
    end
end






