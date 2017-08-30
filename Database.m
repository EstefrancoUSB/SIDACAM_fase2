%% Inicializacion de la base de datos.

codigo_barco = cell(1,20);
max_y_frec = cell(1,20);
N_grabaciones = zeros(1,20);
frec_principales = cell(1,20);
Firma = cell(1,20);
info_barcos = {codigo_barco; max_y_frec; N_grabaciones; frec_principales; Firma};

cambiar = cellfun('isempty',info_barcos{1,1});
info_barcos{1,1}(cambiar) = {'0'};

for barco = 1:length(info_barcos{1,1})
    info_barcos{2,1}{barco} = zeros(2,35,100);
    info_barcos{5,1}{barco} = zeros(4,35);
end

%% Base de datos ruido de fondo
Fecha_ruido_fondo = cell(1,20);
Grabaciones_ruido_fondo = cell(1,20);
Base_ruidos = {Fecha_ruido_fondo;Grabaciones_ruido_fondo};

cambiar = cellfun('isempty',Base_ruidos{1,1});
Base_ruidos{1,1}(cambiar) = {'0'};

% for ruidos = 1:length(Base_ruidos{2,1})
%     Base_ruidos{2,1}{ruidos} = zeros(1,441000);
% end
save('info_barcos','info_barcos')
save('Base_ruidos','Base_ruidos')
