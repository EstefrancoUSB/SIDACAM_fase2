%====ALGORITMO PARA LA DETECCION DE BLANCOS EN EL MAR========
%
% MAIN FILE (MASTER)
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%Este script funcionara como Master, contiene el codigo principal, desde el
%cual se ejecuta la grabacion de ruido de fondo, la extraccion de firmas
%acusticas, y se le da inicio al estado de analisis de deteccion en tiempo
%real de embarcaciones.

%% Inicializacion de variables principales
Dim_fft = 4096;     %Minima longitud de ventana para optima resolucion en FFT.[]
Frec_Corte1 = 300;  %Frecuencia minima de interes. [Hz]
N_Frec = 35;        %Numero de frecuencias para determinas firma acustica. []
Step=50;            %Paso del filtro pasabanda [Hz]
condicion = 1;      %Flag
time = 10;
Frec_Muestreo = 44100;
% Mientras "condicion sea "1" el programa funcionara, al tomar el valor de
% "2" se finaliza
while condicion == 1
    
    modo = menu('Escoja la modalidad de funcionamiento del programa.',...
        'Grabacion ruido de fondo.', 'Extraccion firma acustica.', 'Deteccion de blancos.'...
        ,'SALIR.');  % Selector de estado del programa.
    
    switch modo
        %% Grabacion de ruido de fondo
        case 1
            load Base_ruidos
            
            time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            % Time Debugger
            while ischar(time) || time <=0
                disp('El tiempo de duracion debe ser UN NUMERO mayor que cero')
                time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            end
            
            Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal [Hz]: ');
            % Frec_Muestreo Debugger
            while ischar(Frec_Muestreo) || Frec_Muestreo <=0
                disp('La frecuencia de muestreo debe ser UN NUMERO mayor que cero')
                Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal [Hz]: ');
            end
            
            date=datestr(now);  %Guarda la fecha y la hora actual del PC
            Name_data = ['Ruido_', date(1:6), '_' date(13:14)];
            
            [Ruido_fondo, date] = Grabacion(time,Frec_Muestreo);
            date = str2double(date(13:14))+ 1;
            date = num2str(date);
            Name_data = [Name_data, '-', date];
            
            pos = find((strcmp(Base_ruidos{1,1}, '0')),1);
            Base_ruidos{1}{pos} = Name_data;
            Base_ruidos{2}{pos}= Ruido_fondo';
            
            save('Base_ruidos','Base_ruidos')
            
                      
            
            
            %% Extraccion de Firmas Acusticas
        case 2
            code = input('Ingrese nombre o codigo de la embarcacion: ', 's');
            
            %Se llama la funcion que extrae la firma acustica de la
            %embarcacion
            
            [Max_Bandas_dB, Frec_Max] = Maximo_bandas(code, Dim_fft,...
                Frec_Corte1, N_Frec,Step);
            
            
            %% Deteccion de Blancos
        case 3
            
            [Embarcacion] = Deteccion(time,Frec_Muestreo,Dim_fft, Frec_Corte1, N_Frec, Step);
            fprintf('La embarcacion capturada puede ser: %s \n', Embarcacion)
            
            
        case 4
            condicion = 2;
    end
end
