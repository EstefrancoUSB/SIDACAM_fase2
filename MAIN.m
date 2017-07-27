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
            time = input('Digite cuanto tiempo (en segundos) desea grabar ruido de fondo: ');
            % Time Debugger
            while ischar(time) || time<0 || time==0
                if ischar(time)
                    disp('Ha ingresado letras en vez de numeros')
                else
                    disp('El tiempo de duracion no puede ser menor o igual a cero')
                end
                time = ...
                    input('Digite cuanto tiempo (en segundos) desea grabar ruido de fondo: ');
            end
            Frec_Muestreo = input('Defina la frecuencia de muestreo de la señal: ');
            % Frec_Muestreo Debugger
            while ischar(Frec_Muestreo) || Frec_Muestreo<0 || Frec_Muestreo==0
                if ischar(Frec_Muestreo)
                    disp('Ha ingresado letras en vez de numeros')
                else
                    disp('Ingrese una frecuencia de muestreo valida')
                end
                Frec_Muestreo = ...
                    input('Defina la frecuencia de muestreo de la señal: ');
            end
            date=clock;  %Guarda la fecha y la hora actual desde el reloj interno del PC
            %Nombre para el ruido ambiente
           ambient_noise = input('Defina un nombre para la grabacion de ruido ambiente: ','s');
           ambient_noise = [ambient_noise '_' num2str(date(1)) '_' num2str(date(2)) '_'...
                num2str(date(3)) '_' num2str(date(4)) '_' num2str(date(5)) '.wav']
            [Ruido_fondo, Hora_fondo] = Grabacion(time,Frec_Muestreo,ambient_noise);
            
            %% Extraccion de Firmas Acusticas
        case 2
            code = input('Ingrese nombre o codigo de la embarcacion: ', 's');
            %Analiza en la database si el codigo de la embarcacion ya
            %existe, de lo contrario la almacena
            posicion = find(strcmp(info_barcos{1,1}, code));
            if posicion ~= 0
                Mensaje = ['La embarcacion ya existe en la posicion ', num2str(posicion)];
                disp(Mensaje)
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






