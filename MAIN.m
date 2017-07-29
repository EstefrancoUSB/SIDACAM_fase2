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

% Mientras "condicion sea "1" el programa funcionara, al tomar el valor de
% "2" se finaliza
while condicion == 1
    
    modo = menu('Escoja la modalidad de funcionamiento del programa.',...
        'Grabacion ruido de fondo.', 'Extraccion firma acustica.', 'Deteccion de blancos.'...
        ,'SALIR.');  % Selector de estado del programa.
    
    switch modo
        %% Grabacion de ruido de fondo
        case 1
            time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            % Time Debugger
            while ischar(time) || time<=0
                disp('El tiempo de duracion debe ser UN NUMERO mayor que cero')
                time = input('Digite cuanto tiempo desea grabar ruido de fondo [Segundos]: ');
            end
            
            Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal [Hz]: ');
            % Frec_Muestreo Debugger
            while ischar(Frec_Muestreo) || Frec_Muestreo<=0
                disp('La frecuencia de muestreo debe ser UN NUMERO mayor que cero')
                Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal [Hz]: ');
            end
            
            date=clock;  %Guarda la fecha y la hora actual del PC
            ambient_noise = ['ruido_' num2str(date(1)) '_' num2str(date(2)) '_'...
                num2str(date(3)) '_' num2str(date(4)) '_' num2str(date(5)) '.wav'];
            fprintf('grabando en %s ...',ambient_noise)
            [Ruido_fondo, Hora_fondo] = Grabacion(time,Frec_Muestreo,ambient_noise);
            
            %% Extraccion de Firmas Acusticas
        case 2
            code = input('Ingrese nombre o codigo de la embarcacion: ', 's');
            %Analiza en la database si el codigo de la embarcacion ya
            %existe, de lo contrario la almacena
            posicion = find(strcmp(info_barcos{1,1}, code));
            if posicion ~= 0
                fprintf('La embarcacion ya existe en la posicion %s \n', num2str(posicion))
                fprintf('Numero de grabaciones: %i \n', info_barcos{3,1}(posicion));
            else
                info_barcos{1,1}{find(strcmp(info_barcos{1,1}, '0'),1)} = code;
            end
            
            %Se llama la funcion que extrae la firma acustica de la
            %embarcacion
            [Max_Bandas_dB, Frec_Max,Frecuencias] = Firma_acustica(code, Dim_fft,...
                Frec_Corte1, N_Frec,Step);
            info_barcos{2,1}{find(strcmp(info_barcos{1,1}, '0'),1)} = [Max_Bandas_dB;Frec_Max];
            save('info_barcos')
            
            %% Deteccion de Blancos
        case 3
            [arg_salida3] = Deteccion(argumen_entrada3);
            
        case 4
            condicion = 2;
    end
end
