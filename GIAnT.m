%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main file of the GIAnT tool
% GIAnT was developed for reaseach purposes and is offered free of charge. 
% Commercial use of the tool is prohibited.
% (c) Institute for Communications Technology, TU Braunschweig
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

classdef GIAnT < handle
    properties (Access=private)
       handles
       video
       audio = [];
       var
       show_seconds = 30;
       load_seconds = 60*5;
       shift_seconds = 60*4; 
       cursor_mode = 'search';
       
       h_window_motion
       h_window_motion_grab
       h_window_button_up
       h_comment_panel
       h_annotation_panel
    end
    
    properties (Constant,Access=private)
        base01                     = [88 110  117] * 1/255;
        base02                     = [ 7  54   66] * 1/255;
        base1                      = [147 161 161] * 1/255;
        base2                      = [238 232 213] * 1/255;
        base3                      = [253 246 227] * 1/255;
        base03                     = [0  43    54] * 1/255;
        red                        = [142 22   45] * 1/255;
        cyan                       = [42 161  152] * 1/255;
        green                      = [133 148  53] * 1/255;
        yellow                     = [181 137   0] * 1/255;
        blue                       = [38 139  210] * 1/255;
        grey                       = [199 199 199] * 1/255;
        darkgrey                   = [111 111 111] * 1/255;
        darkergrey                 = [89   89  89] * 1/255;
        lightblue                  = [214 231 237] * 1/255;
         
        width_of_axes = 0.75;
        space_between_axes = 0.118;
        
        edit_icon = imread('./bin/icons/iconEdit.jpg');
        search_icon = imread('./bin/icons/iconNavigate.jpg');
        zoom_in_icon = imread('./bin/icons/iconZoomIN.jpg');
        zoom_out_icon = imread('./bin/icons/iconZoomOUT.jpg');
        redbutton_icon = imread('./bin/icons/iconRedButton.jpg');
        
        tubs_logo = imread('./bin/logos/tu-logo.png');
        ifn_logo = imread('./bin/logos/IfN_Logo.jpg');
        
        % increase this value to reduce the quality and to increase the
        % performance:
        quality_of_plot = 2;
        
        name_of_tmp_folder = '.tmp';
        
        vers = '1.2.0';
    end
    
    methods
        
        
        %% Constructor
        function obj = GIAnT()
            obj.handles.fig = figure(...
                'Visible',      'on', ...
                'Position',     [000,0,1500,1000], ...
                'Renderer', 'opengl',...
                'GraphicsSmoothing', 'off',...
                'Toolbar','none',...
                'Units', 'pixels',...
                'Name', ['AnnotationTool v',obj.vers],...
                'NumberTitle','off',...
                'MenuBar',      'none');
            
            opengl software
                     
            % Initialize GUI
            obj.init_panels();
            obj.init_var();
            obj.set_callbacks();
                           
            % Maximize figure to fullscreen:
            drawnow; % Required to avoid Java errors
            jFig = get(handle(obj.handles.fig), 'JavaFrame');
            jFig.setFigureIcon(javax.swing.ImageIcon('./bin/logos/logoG.png'));
%             jFig.setMaximized(true);

            sz = [1200 675];
            screensize = get(0,'ScreenSize');
            xpos = ceil((screensize(3)-sz(1))/2);
            ypos = ceil((screensize(4)-sz(2))/2);
            obj.handles.fig.Position = [xpos,ypos,sz(1),sz(2)];    

            obj.init_key();    
        end
        
        %% init_panels
        % initializes the panels and buttons of the gui
        function init_panels(obj)
            import java.awt.*;
            % init toolbar
            obj.handles.toolbar = uitoolbar(obj.handles.fig);
            obj.handles.edit_tool = uitoggletool(obj.handles.toolbar,...
                'CData', obj.edit_icon, 'TooltipString','Edit','Separator','off',...
                'Tag','edit');
            obj.handles.search_tool = uitoggletool(obj.handles.toolbar,...
                'CData', obj.search_icon, 'TooltipString','Search','Separator','off',...
                'Tag','search','State','on');
            obj.handles.zoom_in_tool = uitoggletool(obj.handles.toolbar,...
                'CData', obj.zoom_in_icon, 'TooltipString','Zoom In','Separator','off',...
                'Tag','zoomin');
            obj.handles.zoom_out_tool = uitoggletool(obj.handles.toolbar,...
                'CData', obj.zoom_out_icon, 'TooltipString','Zoom Out','Separator','off',...
                'Tag','zoomout');
            
            obj.handles.level_two_tool = uitoggletool(obj.handles.toolbar,...
                'CData', obj.redbutton_icon, 'TooltipString','Create Level 2','Separator','on',...
                'Tag','leveltwo');
                    
            obj.handles.main_panel = uipanel(...
               'Parent', obj.handles.fig,...
               'Units', 'normalized',...
               'Position', [0, 0 ,1 ,1],...
               'BackgroundColor',  obj.lightblue,...obj.base3,...
               'Visible', 'on');
           
           obj.handles.left_main_panel = uipanel(...
               'Parent', obj.handles.main_panel,...
               'Units', 'normalized',...
               'Position', [0.005, 0 ,.2 ,1],...
               'BackgroundColor',  obj.lightblue,...
               'HighlightColor',  obj.lightblue,...
               'ShadowColor',  obj.lightblue,...
               'Visible', 'on');
           
           obj.handles.tubs_logo_axes = axes(...
               'Parent', obj.handles.left_main_panel,...
               'Units', 'normalized',...
               'Position', [0, .94, .5, .04],...[0.005, 0.94 ,.1 ,.04],...
               'Visible', 'on');
           
           obj.handles.ifn_logo_axes = axes(...
               'Parent', obj.handles.left_main_panel,...
               'Units', 'normalized',...
               'Position', [0.5, .94, .5,.05],...[0.105, 0.94 ,.1 ,.05],...
               'Color', [1 1 1],...
               'Visible', 'on');

           obj.handles.main_axes = axes(...
               'Parent', obj.handles.main_panel,...
               'Units', 'normalized',...
               'Position', [0, 0 ,1 ,1],...
               'Visible', 'off');
              
           obj.handles.video_axes = axes(...
               'Parent', obj.handles.left_main_panel,...
               'Units', 'normalized',...
               'Position', [0, .72, 1, .2],...[0.005, 0.72 ,.2 ,.2],...
               'Visible', 'on');
           obj.handles.video_axes.XTick = [];
           obj.handles.video_axes.YTick = [];
           obj.handles.video_axes.XColor_I = obj.handles.main_panel.BackgroundColor;
           obj.handles.video_axes.YColor_I = obj.handles.main_panel.BackgroundColor;
           
           obj.handles.video_checkbox = uicontrol(...
               'Parent', obj.handles.main_panel,...
               'Units', 'normalized',...
               'Style', 'checkbox',...
               'String','Video On/Off',...
               'Position', [0.005, 0.7 ,.2 ,.013],...
               'BackgroundColor',  obj.handles.main_panel.BackgroundColor,...
               'Visible', 'on');
           
           obj.handles.custom_keyboard_checkbox = uicontrol(...
               'Parent', obj.handles.main_panel,...
               'Units', 'normalized',...
               'Style', 'checkbox',...
               'Value', 1,...
               'String','Using CustomKeyboard',...
               'Position', [0.005, 0.675 ,.2 ,.015],...
               'BackgroundColor',  obj.handles.main_panel.BackgroundColor,...
               'Visible', 'on');
           
           obj.handles.play_stop_panel = uipanel(...
               'Parent', obj.handles.main_panel,...
               'Units', 'normalized',...
               'Position', [0.005, 0.01 ,.2 ,.2],...
               'BackgroundColor',  obj.grey,...obj.base03,...
               'ShadowColor',  obj.grey,...
               'HighlightColor',  obj.grey,...
               'Visible', 'on');
           
           obj.handles.play_button = uipanel(...
               'Parent', obj.handles.play_stop_panel,...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'Position', [0.1, 0.68 ,.2 ,.15],...
               'Title', 'Play',...
               'FontSize' , 25, ...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.darkergrey,...obj.base01,...
               'ShadowColor', obj.darkergrey,...obj.base01,...
               'HighlightColor', obj.darkergrey,...obj.base01,...
               'TitlePosition', 'CenterBottom',...
               'visible','on');
           
           obj.handles.vad_button = uipanel(...
               'Parent', obj.handles.play_stop_panel,...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'Position', [0.4, 0.38 ,.2 ,.15],...
               'Title', 'SAD',...
               'FontSize' , 25, ...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.darkergrey,...obj.base01,...
               'ShadowColor', obj.darkergrey,...obj.base01,...
               'HighlightColor', obj.darkergrey,...obj.base01,...
               'TitlePosition', 'CenterBottom',...
               'visible','on');
           
           obj.handles.save_button = uipanel(...
               'Parent', obj.handles.play_stop_panel,...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'Position', [0.4, 0.68 ,.2 ,.15],...
               'Title', 'Save',...
               'FontSize' , 25, ...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.darkergrey,...obj.base01,...
               'ShadowColor', obj.darkergrey,...obj.base01,...
               'HighlightColor', obj.darkergrey,...obj.base01,...
               'TitlePosition', 'CenterBottom',...
               'visible','on');
                       
           obj.handles.load_button = uipanel(...
               'Parent', obj.handles.play_stop_panel,...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'Position', [0.1, 0.38 ,.2 ,.15],...
               'Title', 'Load',...
               'FontSize' , 25, ...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.blue,...obj.green,...
               'ShadowColor', obj.blue,...obj.green,...
               'HighlightColor', obj.blue,...obj.green,...
               'TitlePosition', 'CenterBottom',...
               'visible','on');
           
           obj.handles.key_button = uipanel(...
               'Parent', obj.handles.play_stop_panel,...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'Position', [0.7, 0.68 ,.2 ,.15],...
               'Title', 'Key',...
               'FontSize' , 25, ...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.blue,...obj.green,...
               'ShadowColor', obj.blue,...obj.green,...
               'HighlightColor', obj.blue,...obj.green,...
               'TitlePosition', 'CenterBottom',...
               'visible','on');
           
           obj.handles.annotation_panel = uipanel(...
               'Parent', obj.handles.main_panel,...
               'Units', 'normalized',...
               'Position', [0.005, 0.51 , .2, .15],...
               'BackgroundColor',  obj.grey,...
               'ShadowColor',  obj.grey,...
               'HighlightColor',  obj.grey,...
               'Visible', 'on');
           
           obj.handles.annotation_jtext_pane = javax.swing.JTextPane();
           obj.handles.annotation_jscroll_pane = javax.swing.JScrollPane(obj.handles.annotation_jtext_pane);
           [obj.handles.annotation_component, obj.handles.annotation_container] ...
               = javacomponent(obj.handles.annotation_jscroll_pane, [], obj.handles.annotation_panel, {});
           set(obj.handles.annotation_container, 'units', 'normalized', 'position', [0.05,0.63,.9,.2], 'visible', 'on');
           java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
                obj.handles.annotation_jtext_pane.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 15));
                obj.handles.annotation_jtext_pane.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
                obj.handles.annotation_jtext_pane.setEditable(false);
                obj.handles.annotation_jtext_pane.setEnabled(false);
           
            obj.handles.annotation_str = uicontrol(...
                'Parent',obj.handles.annotation_panel,...
                'Units', 'normalized',...
                'Style', 'Text',...
                'FontSize',9,...
                'HorizontalAlignment','left',...
                'String','Annotation:',...
                'Backgroundcolor',obj.handles.annotation_panel.BackgroundColor,...
                'ForegroundColor', 'k',...obj.green,...
                'Position', [0.05, 0.85, .9, .1],...
                'visible','on');
            
            obj.handles.comment_jtext_pane = javax.swing.JTextPane();
           obj.handles.comment_jscroll_pane = javax.swing.JScrollPane(obj.handles.comment_jtext_pane);
           [obj.handles.comment_component, obj.handles.comment_container] ...
               = javacomponent(obj.handles.comment_jscroll_pane, [], obj.handles.annotation_panel, {});
           set(obj.handles.comment_container, 'units', 'normalized', 'position', [0.05,0.1,.9,.35], 'visible', 'on');
           java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
                obj.handles.comment_jtext_pane.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 13));
                obj.handles.comment_jtext_pane.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
                obj.handles.comment_jtext_pane.setEditable(false);
                obj.handles.comment_jtext_pane.setEnabled(false);
            
           obj.handles.comment_str = uicontrol(...
                'Parent',obj.handles.annotation_panel,...
                'Units', 'normalized',...
                'Style', 'Text',...
                'FontSize',9,...
                'HorizontalAlignment','left',...
                'String','Comment:',...
                'Backgroundcolor',obj.handles.annotation_panel.BackgroundColor,...
                'ForegroundColor', 'k',...obj.green,...
                'Position', [0.05, 0.47, .9, .1],...
                'visible','on');
            
           obj.handles.channel_panel = uipanel(...
               'Parent', obj.handles.main_panel,...
               'Units', 'normalized',...
               'Position', [0.005, 0.35 , .2, .15],...
               'BackgroundColor',  obj.grey,...obj.base03,...
               'ShadowColor',  obj.grey,...
               'HighlightColor',  obj.grey,...
               'Visible', 'on');
           
           for ii=1:8
               jj = 0;
               if ii>4
                   jj = .43;
               end
               obj.handles.channel_str(ii) = uicontrol(...
                   'Parent',obj.handles.channel_panel,...
                   'Units', 'normalized',...
                   'FontUnits', 'pixels',...
                   'Style', 'Text',...
                   'FontSize',12,...
                   'HorizontalAlignment','left',...
                   'String',['Channel ',num2str(ii)],...
                   'Backgroundcolor',obj.handles.channel_panel.BackgroundColor,...
                   'ForegroundColor', 'k',...obj.green,...
                   'Position', [(.05+jj) (.82 - (mod(ii-1,4))*.24) .59 .12],...
                   'visible','on');
           end
           
           for ii=1:8 
               jj = 0;
               if ii>4
                  jj = .43;
               end
               obj.handles.mute_panel(ii) = uipanel(...
               'Parent',obj.handles.channel_panel,...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'Title', 'M',...
               'FontSize', 17,...
               'TitlePosition', 'CenterBottom',...
               'Position', [(.23+jj) (.82 - (mod(ii-1,4))*.24) .06 .13],...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.darkergrey,...obj.base01,...
               'ShadowColor', obj.darkergrey,...obj.base01,...
               'HighlightColor', obj.darkergrey,...obj.base01,...
               'visible','on');
           end
           
           for ii=1:8   
               jj = 0;
               if ii>4
                  jj = .43;
               end
               obj.handles.solo_panel(ii) = uipanel(...
               'Parent',obj.handles.channel_panel,...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'Title', 'S',...
               'FontSize', 17,...
               'TitlePosition', 'CenterBottom',...
               'Position', [(.31+jj) (.82 - (mod(ii-1,4))*.24) .06 .13],...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.darkergrey,...obj.base01,...
               'ShadowColor', obj.darkergrey,...obj.base01,...
               'HighlightColor', obj.darkergrey,...obj.base01,...
               'visible','on');
           end
            
           obj.handles.current_time_panel = uipanel(...
               'Parent',obj.handles.play_stop_panel,...
               'Title', 'Time:',...
               'FontSize',11,...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.red,...
               'ShadowColor', obj.red,...
               'HighlightColor', obj.red,...
               'TitlePosition', 'CenterTop',...
               'Units', 'normalized',...
               'Position', [0.05 0.05 .4 .25],...
               'visible','on');
           
           obj.handles.current_time_str = uicontrol(...
               'Parent',obj.handles.current_time_panel,...
               'Style', 'text',...
               'String',sprintf('%02.0f:%02.0f:%02.0f:%03.0f', 0, 0, 0, 0),...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'FontSize',19,...
               'Backgroundcolor',obj.handles.current_time_panel.BackgroundColor,...
               'Foregroundcolor',[1 1 1],...
               'Position', [0 0.12 1 1],...
               'visible','on');
           
           obj.handles.total_time_panel = uipanel(...
               'Parent',obj.handles.play_stop_panel,...
               'Title', 'Total:',...
               'FontSize',11,...
               'ForegroundColor', [1 1 1],...
               'BackgroundColor', obj.base01,...
               'ShadowColor', obj.base01,...
               'HighlightColor', obj.base01,...
               'TitlePosition', 'CenterTop',...
               'Units', 'normalized',...
               'Position', [0.55 0.05 .4 .25],...
               'visible','on');
           
           obj.handles.total_time_str = uicontrol(...
               'Parent',obj.handles.total_time_panel,...
               'Style', 'text',...
               'String',sprintf('%02.0f:%02.0f:%02.0f:%03.0f', 0, 0, 0, 0),...
               'Units', 'normalized',...
               'FontUnits', 'pixels',...
               'FontSize',19,...
               'Backgroundcolor',obj.handles.total_time_panel.BackgroundColor,...
               'Foregroundcolor',[1 1 1],...
               'Position', [0 0.12 1 1],...
               'visible','on');
           
           obj.handles.time_slider = uicontrol(...
               'Parent',obj.handles.fig,...
               'Style', 'slider',...
               'Units', 'normalized',...
               'Position', [0.23 0.01 obj.width_of_axes .012],...
               'Enable', 'Off',...
               'visible','on');
           
           obj.handles.keyname_str = uicontrol(...
                'Parent',obj.handles.play_stop_panel,...
                'Units', 'normalized',...
                'Style', 'Text',...
                'FontSize',9,...
                'HorizontalAlignment','left',...
                'String','Loaded Key: None',...
                'Backgroundcolor',obj.handles.play_stop_panel.BackgroundColor,...
                'ForegroundColor', 'k',...obj.green,...
                'Position', [0.01, 0.9, .9, .09],...
                'visible','on');
        end
        
        %% set_callbacks
        function set_callbacks(obj)
            set(obj.handles.fig,'WindowKeyReleaseFcn',@obj.callback_windowkey_release);
            set(obj.handles.fig,'WindowKeyPressFcn',@obj.callback_windowkey_press);
            set(obj.handles.play_button,  'ButtonDownFcn', @obj.callback_play);
            set(obj.handles.save_button,  'ButtonDownFcn', @obj.callback_export_to_excel);
            set(obj.handles.load_button,  'ButtonDownFcn', @obj.callback_load);
            set(obj.handles.key_button,  'ButtonDownFcn', @obj.init_key);
            set(obj.handles.vad_button,  'ButtonDownFcn', @obj.callback_vad_processing);
            set(obj.handles.edit_tool,  'ClickedCallback', @obj.callback_clicked_toggle);
            set(obj.handles.search_tool,  'ClickedCallback', @obj.callback_clicked_toggle);
            set(obj.handles.zoom_in_tool,  'ClickedCallback', @obj.callback_clicked_toggle);
            set(obj.handles.zoom_out_tool,  'ClickedCallback', @obj.callback_clicked_toggle);
            set(obj.handles.level_two_tool,  'ClickedCallback', @obj.callback_clicked_toggle);
            obj.h_comment_panel = handle(obj.handles.comment_jtext_pane,'CallbackProperties');
            set(obj.h_comment_panel,'KeyReleasedCallback',@obj.callback_comment_keytyping);
            obj.h_annotation_panel = handle(obj.handles.annotation_jtext_pane,'CallbackProperties');
            set(obj.h_annotation_panel,'KeyReleasedCallback',@obj.callback_annotation_keytyping);
            set(obj.h_annotation_panel,'FocusLostCallback',@obj.callback_annotation_focuslost);
            set(obj.handles.fig,'SizeChangedFcn',@obj.callback_resize);
            
     
            obj.h_window_motion = iptaddcallback(...
               obj.handles.fig,...
               'WindowButtonMotionFcn',...
               @obj.drag_and_drop);
           
            set(obj.handles.fig,'CloseRequestFcn',@obj.callback_close_figure);
        end
                
        %% Callback_resize
        % executes when size of main window is changed
        function callback_resize(obj, hObject, eventData)
            obj.handles.channel_panel.Units = 'pixels';
            fontsize = 12/382.2 * obj.handles.channel_panel.Position(3);
            fontsize_panel = 16.5/382.2 * obj.handles.channel_panel.Position(3);
            for ii=1:8
                obj.handles.channel_str(ii).FontSize = fontsize;
                obj.handles.mute_panel(ii).FontSize = fontsize_panel;
                obj.handles.solo_panel(ii).FontSize = fontsize_panel;
            end
            obj.handles.channel_panel.Units = 'normalized';
            
            obj.handles.load_button.Units = 'pixels';
            fontsize_panel = 25/76 * obj.handles.load_button.Position(3);
            obj.handles.load_button.FontSize = fontsize_panel;
            obj.handles.play_button.FontSize = fontsize_panel;
            obj.handles.save_button.FontSize = fontsize_panel;
            obj.handles.key_button.FontSize = fontsize_panel;
            obj.handles.vad_button.FontSize = fontsize_panel;
            obj.handles.load_button.Units = 'normalized';
            
            obj.handles.total_time_panel.Units = 'pixels';
            a = 19.5/152 * obj.handles.total_time_panel.Position(3);
            b = 19.5/39.4 * obj.handles.total_time_panel.Position(4);
            if a < b
                fontsize = a;
            else
                fontsize = b;
            end
            obj.handles.total_time_str.FontSize = fontsize;
            obj.handles.current_time_str.FontSize = fontsize;
            obj.handles.total_time_panel.Units = 'normalized';
            
            
           obj.handles.tubs_logo_axes.Units = 'pixels';
           obj.handles.tubs_logo_axes.Position(4) = size(obj.tubs_logo,1)/size(obj.tubs_logo,2) * obj.handles.tubs_logo_axes.Position(3);
           RI = imref2d(size(obj.tubs_logo),obj.handles.tubs_logo_axes.Position(3)/size(obj.tubs_logo,2),obj.handles.tubs_logo_axes.Position(4)/size(obj.tubs_logo,1));
           imshow(obj.tubs_logo,RI,'Parent',obj.handles.tubs_logo_axes);
           obj.handles.tubs_logo_axes.XTick = [];
           obj.handles.tubs_logo_axes.YTick = [];
           obj.handles.tubs_logo_axes.Units = 'normalized';
           obj.handles.tubs_logo_axes.XColor_I = obj.handles.main_panel.BackgroundColor;
           obj.handles.tubs_logo_axes.YColor_I = obj.handles.main_panel.BackgroundColor;
           obj.handles.tubs_logo_axes.Position(2) = .9972 - obj.handles.tubs_logo_axes.Position(4);
           
           obj.handles.ifn_logo_axes.Units = 'pixels';
           obj.handles.ifn_logo_axes.Position(4) = size(obj.ifn_logo,1)/size(obj.ifn_logo,2) * obj.handles.ifn_logo_axes.Position(3);
           RI = imref2d(size(obj.ifn_logo),obj.handles.ifn_logo_axes.Position(3)/size(obj.ifn_logo,2),obj.handles.ifn_logo_axes.Position(4)/size(obj.ifn_logo,1));
           imshow(obj.ifn_logo,RI,'Parent',obj.handles.ifn_logo_axes);
           obj.handles.ifn_logo_axes.XTick = [];
           obj.handles.ifn_logo_axes.YTick = [];
           obj.handles.ifn_logo_axes.XColor_I = obj.handles.main_panel.BackgroundColor;
           obj.handles.ifn_logo_axes.YColor_I = obj.handles.main_panel.BackgroundColor;
           obj.handles.ifn_logo_axes.Units = 'normalized';
           middle = obj.handles.tubs_logo_axes.Position(2) + obj.handles.tubs_logo_axes.Position(4)/2;
           obj.handles.ifn_logo_axes.Position(2) = middle - obj.handles.ifn_logo_axes.Position(4)/2;
            
        end
        
        %% WindowButtonMotionFcn drag_and_drop
        % executed after every mouse motion
        % function just to change the kind of mouse cursor
        function drag_and_drop(obj, hObject, eventData)
            if obj.var.audio_loaded
                
                switch obj.cursor_mode
                    % if tool for level 2 sets is selected do nothing
                    case 'leveltwo'
                        
                    otherwise
                        % look over all axes
                        for ii=1:length(obj.handles.soundwave_axes)
                            mouse_pos = get(obj.handles.soundwave_axes(ii), 'currentpoint');
                            x_mouse = mouse_pos(1,1);
                            y_mouse = mouse_pos(1,2);
                            
                            % extract bounds of whole soundwave_axes(ii):
                            x_axes_min  = obj.handles.soundwave_axes(ii).XLim(1);
                            x_axes_max  = obj.handles.soundwave_axes(ii).XLim(2);
                            y_axes_min  = obj.handles.soundwave_axes(ii).YLim(1);
                            y_axes_max  = obj.handles.soundwave_axes(ii).YLim(2);
                            
                            % if mouse position is within the current axes
                            if x_mouse >= x_axes_min && x_mouse <= (x_axes_max)&& ...
                                    y_mouse >= y_axes_min && y_mouse <= (y_axes_max)
                                
                                switch obj.cursor_mode
                                    case 'search'
                                        setfigptr('hand', obj.handles.fig);
                                    case 'zoomin'
                                        setfigptr('zoomin', obj.handles.fig);
                                    case 'zoomout'
                                        setfigptr('zoomout', obj.handles.fig);
                                    case 'edit'
                                        if obj.var.vad_tagged(1) == ii
                                            obj.set_drag_ptr();
                                        else
                                            setfigptr('matlabdoc', obj.handles.fig);
                                        end
                                        
                                end
                                return;
                            else
                                setfigptr('default', obj.handles.fig);
                            end
                        end
                end
            end
        end
        
        %% set_drag_ptr
        % figure out if mouse position is close to a vad bound and set
        % mouse pointer due to it.
        function set_drag_ptr(obj)
            if obj.var.vad_tagged
                speaker = obj.var.vad_tagged(1);
                lower_bound = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData(1);
                higher_bound = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData(2);
                mouse_pos = get(obj.handles.soundwave_axes(speaker), 'currentpoint');
                x_mouse = mouse_pos(1,1);
                range = obj.show_seconds * obj.var.fs * 0.00004;
                if x_mouse >= lower_bound-range && x_mouse <= lower_bound+range
                    setfigptr('left', obj.handles.fig);
                elseif x_mouse >= higher_bound-range && x_mouse <= higher_bound+range
                    setfigptr('right', obj.handles.fig);
                else
                    setfigptr('matlabdoc', obj.handles.fig);
                end
            end
        end
        
        %% callback_axes
        % executes when user clicks on any visible axes
        function callback_axes(obj, hObject, eventData)
            switch obj.cursor_mode
                case 'search'
                    % navigate within the axes
                    obj.grab(hObject, eventData)
                case 'zoomin'
                    if strcmp(obj.handles.fig.SelectionType,'open')
                        obj.show_seconds = 15;
                    else
                        obj.show_seconds = obj.show_seconds/2;
                    end
                    obj.update_soundwave_plot_zoom();
                case 'zoomout'
                    if strcmp(obj.handles.fig.SelectionType,'open')
                        obj.show_seconds = 15;
                    else
                        obj.show_seconds = obj.show_seconds*2;
                    end
                    obj.update_soundwave_plot_zoom();
                case 'edit'
                    % if edit mode and cursor is over a patch and also the
                    % pointer isn't a left or right arrow, do this:
                    if strcmp(obj.handles.fig.SelectionType,'normal')
                        if isa(hObject,'matlab.graphics.primitive.Patch') && strcmp(obj.handles.fig.Pointer,'custom')
                            % if a vad is already tagged, untag it
                            if obj.var.vad_tagged
                                if isempty(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Code)
                                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.yellow;
                                else
                                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.green;
                                end
                            end
                            if obj.var.vad_tagged == hObject.UserData.ID
                                obj.var.vad_tagged = [0 0];
                            else
                                hObject.FaceColor = obj.red;
                                obj.var.vad_tagged = hObject.UserData.ID;
                            end
                            obj.show_info();
                        end
                        % if pointer is a left or right arrow, do this:
                        if ~strcmp(obj.handles.fig.Pointer,'custom') && ~strcmp(obj.handles.fig.Pointer,'arrow')
                            obj.set_dragging_vad();
                        end
                    % if user pressed the right mouse button and wants to generate a new vad segment    
                    elseif strcmp(obj.handles.fig.SelectionType,'alt')
                        if ~isa(hObject,'matlab.graphics.primitive.Patch') && strcmp(obj.handles.fig.Pointer,'custom')
                            obj.generate_new_vad(hObject, eventData);
                        end
                    % if user holds shift and pressed the left mouse button and wants to merge vad segments    
                    elseif strcmp(obj.handles.fig.SelectionType,'extend')
                        if isa(hObject,'matlab.graphics.primitive.Patch') && strcmp(obj.handles.fig.Pointer,'custom')
                            if obj.var.vad_tagged
                                % if user clicks on the already tagged vad,
                                % untag it:
                                if obj.var.vad_tagged == hObject.UserData.ID
                                    if isempty(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Code)
                                        obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.yellow;
                                    else
                                        obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.green;
                                    end
                                    obj.var.vad_tagged = [0 0];
                                else
                                    merge_vad_id = hObject.UserData.ID;
                                    if obj.var.vad_tagged(1) ~= merge_vad_id(1)
                                       disp('You cannot merge SADs from different speakers'); 
                                       return; 
                                    end
                                    speaker = obj.var.vad_tagged(1);
                                    max_vad_nr = max(merge_vad_id(2),obj.var.vad_tagged(2));
                                    min_vad_nr = min(merge_vad_id(2),obj.var.vad_tagged(2));
                                    
                                    Onset = Inf;
                                    Offset = 0;
                                    for ii=min_vad_nr:max_vad_nr
                                        if obj.audio.data(speaker).vad(ii).Onset < Onset
                                           Onset = obj.audio.data(speaker).vad(ii).Onset;
                                        end
                                        if obj.audio.data(speaker).vad(ii).Offset > Offset
                                           Offset = obj.audio.data(speaker).vad(ii).Offset;
                                        end
                                        if obj.var.vad_tagged(2) ~= ii
                                            obj.audio.data(speaker).vad(ii).Deleted = true;
                                            delete(obj.audio.data(speaker).vad(ii).Object);
                                            delete(obj.audio.data(speaker).vad(ii).TextObject);
                                        end
                                    end
                                    xdata = [Onset Offset Offset Onset];
                                    xdata = obj.time_to_sample_in_plot(xdata);
                                    obj.audio.data(speaker).vad(obj.var.vad_tagged(2)).Onset = Onset;
                                    obj.audio.data(speaker).vad(obj.var.vad_tagged(2)).Offset = Offset;
                                    obj.audio.data(speaker).vad(obj.var.vad_tagged(2)).Object.XData = xdata;
                                    obj.audio.data(speaker).vad(obj.var.vad_tagged(2)).PlotData = xdata;
                                    obj.audio.data(speaker).vad(obj.var.vad_tagged(2)).TextObject.Position(1) = xdata(1);
                                    obj.sort_vads(speaker);
                                    obj.var.vad_tagged(2) = min_vad_nr;
                                end
                                
                                
                            else
                                hObject.FaceColor = obj.red;
                                obj.var.vad_tagged = hObject.UserData.ID;
                            end
                        end
                    end
                
            end
            
        end
        
        %% callback_vad_processing
        % executes if vad button is clicked
        function callback_vad_processing(obj, hObject, eventData)
            set(obj.handles.vad_button,'BackgroundColor', obj.red);
            set(obj.handles.vad_button,'ShadowColor', obj.red);
            set(obj.handles.vad_button,'HighlightColor', obj.red);
            
            if ~obj.var.SAD_exist
                
                choice = questdlg('Do you want to start the automatic SAD recognition? This may take some time!','Automatic SAD recognition','Yes','No','Yes');
                
                switch choice
                    case 'No'
                        
                        
                    case 'Yes'
                        obj.create_dialog_window();
                        drawnow;

                        obj.start_sad_processing();
                        delete(obj.handles.dialog);
                        if ~obj.var.sad_canceled
                            block_msg_cleanup = obj.set_info_text_at_loading();
                            obj.plot_automatic_vads();
                        end
                        clear block_msg_cleanup;
                end
            end
            set(obj.handles.vad_button,'BackgroundColor', obj.blue);
            set(obj.handles.vad_button,'ShadowColor', obj.blue);
            set(obj.handles.vad_button,'HighlightColor', obj.blue);
        end
        
        %% create_dialog_window
        % creates a dialog window for showing current state of the
        % Processing and giving the opportunity to cancel it.
        function create_dialog_window(obj)
            obj.var.sad_canceled = false;
            obj.handles.dialog = dialog('WindowStyle', 'normal', 'Name', 'SAD Processing','Position',[680 558 250 150]);
            obj.handles.dialog_string = uicontrol('Parent',obj.handles.dialog,'Style','Text','String','Start PreProcessing.','Position',[10 50 210 100],'FontSize',14);
            obj.handles.dialog_cancel_button = uicontrol('Parent',obj.handles.dialog,'Style','Pushbutton','String','Cancel','Position',[80 20 60 30],'FontSize',12);
            set(obj.handles.dialog_cancel_button, 'Callback',@obj.sad_cancel);
            obj.handles.dialog.CloseRequestFcn = [];
        end
        
        %% sad_cancel
        % if sad is canceled
        function sad_cancel(obj, hObject, eventData)
            obj.var.sad_canceled = true;
        end
        
        %% callback_time_axes_beyond
        % executes if there is a click on the unvisible axes behind the
        % soundwave axes
        function callback_time_axes_beyond(obj, hObject, eventData)
            
            % determine ranges depending on first and last soundwave axes
            mouse_pos = get(obj.handles.soundwave_axes(1), 'currentpoint');
            x_pos = mouse_pos(1,1);
            scale = obj.handles.soundwave_axes(1).YLim(2);
            y_top = (mouse_pos(1,2) - scale) - scale * .5;
            mouse_pos = get(obj.handles.soundwave_axes(end), 'currentpoint');
            scale = obj.handles.soundwave_axes(end).YLim(2);
            y_bottom = mouse_pos(1,2) + scale * 1.7;
            x_range_left = x_pos - obj.handles.soundwave_axes(1).XLim(1);
            x_range_right = x_pos - obj.handles.soundwave_axes(1).XLim(2);
            
            if y_top < 0 && y_bottom > 0 && x_range_left > 0 && x_range_right < 0
                switch obj.cursor_mode
                    case 'leveltwo'
                        obj.determine_level_two_segment(hObject, eventData);
                        
                    % move time cursor to this position
                    otherwise
                        % stop playback if necessary
                        if obj.var.is_playing
                            obj.play(obj.handles.play_button, eventData);
                        end
                        
                        obj.handles.timer_cursor.XData = [x_pos x_pos];
                        CurrentTime = datevec(round(obj.handles.timer_cursor.XData(1) *obj.var.qp + obj.var.delay_in_sample)/obj.audio.reference.SampleRate/86400);
                        obj.handles.current_time_str.String = sprintf('%02.0f:%02.0f:%02.0f:%03.0f', CurrentTime(4), CurrentTime(5), fix(CurrentTime(6)), fix((CurrentTime(6)-fix(CurrentTime(6)))*1000) );
                        obj.update_time_slider();
                        obj.set_reference_new_with_timecursor();
                        drawnow;
                        if obj.handles.video_checkbox.Value
                            obj.update_video_frame();
                        end
                        
                        % resume playback if necessary
                        if obj.var.is_playing
                            obj.play(obj.handles.play_button, eventData);
                        end
                end
            end
        end
        
        %% generate_new_vad
        function generate_new_vad(obj, hObject, eventData)
            % if a vad is already tagged, untag it.
            if obj.var.vad_tagged
                if isempty(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Code)
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.yellow;
                else
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.green;
                end
            end
            
            % determine the speaker nr
            if isa(hObject,'matlab.graphics.axis.Axes')
                ID = hObject.UserData.ID;
            else
                ID = hObject.Parent.UserData.ID;
            end
            
            log = strncmp(fieldnames(obj.audio.data(ID)),'vad',3);
            if sum(log) > 0
                vad_nr = length(obj.audio.data(ID).vad) + 1;
            else
                vad_nr = 1;
            end
            
            mouse_pos = get(obj.handles.soundwave_axes(ID), 'currentpoint');
            pos_x = mouse_pos(1,1);
            range = obj.var.fs/obj.var.qp * .5;
            obj.audio.data(ID).vad(vad_nr).Onset = obj.sample_in_plot_to_time(pos_x - range);
            obj.audio.data(ID).vad(vad_nr).Offset = obj.sample_in_plot_to_time(pos_x + range);
            obj.audio.data(ID).vad(vad_nr).Code = '';
            obj.audio.data(ID).vad(vad_nr).Memo = '';
            
            start_pt = obj.time_to_sample_in_plot(obj.audio.data(ID).vad(vad_nr).Onset);
            end_pt = obj.time_to_sample_in_plot(obj.audio.data(ID).vad(vad_nr).Offset);
            xdata = [start_pt; end_pt; end_pt; start_pt];
            y = obj.handles.soundwave_axes(ID).YLim(2);
            ydata = [y; y; -y; -y];
            zdata = zeros(4,1);
            obj.audio.data(ID).vad(vad_nr).PlotData = xdata;
            obj.audio.data(ID).vad(vad_nr).Object = patch(xdata,ydata,zdata,'parent',obj.handles.soundwave_axes(ID),'FaceColor', obj.red, 'FaceAlpha' , 0.3);
            set(obj.audio.data(ID).vad(vad_nr).Object, 'ButtonDownFcn', @obj.callback_axes);
            obj.audio.data(ID).vad(vad_nr).Object.UserData.ID = [ID vad_nr];
            obj.audio.data(ID).vad(vad_nr).TextObject = text(start_pt,double(y*1.1),obj.audio.data(ID).vad(vad_nr).Code,'Parent',obj.handles.soundwave_axes(ID),'Interpreter','none');
            obj.audio.data(ID).vad(vad_nr).Deleted = false;
            obj.var.vad_tagged = obj.audio.data(ID).vad(vad_nr).Object.UserData.ID;
            obj.show_info();
            obj.sort_vads(ID, vad_nr);
        end
        
        %% determine_level_two_segment
        function determine_level_two_segment(obj, hObject, eventData)
            
            % if mouse is clicked on a lvl2 line, prepare for dragging
            if isa(hObject,'matlab.graphics.primitive.Line')
                obj.var.lvl2_nr = hObject.UserData.Nr;
                obj.show_info();
                obj.set_dragging_lvltwo_line(hObject, eventData)
            % if not check wether they exist other lvl2 segments and ask what to do or
            % create a new lvl2 segment
            else
                mouse_pos = get(obj.handles.time_cursor_axes, 'currentpoint');
                mouse_pos = mouse_pos(1,1);
                
                log = strncmp(fieldnames(obj.audio),'lvl_two',7);
                
                if sum(log) > 0 && ~isempty(obj.audio.lvl_two)
                   options = {'Create a new Level 2 Set';'Move an existing bound'};
                   [s,v] = listdlg('PromptString','Select a option:',...
                    'SelectionMode','single',...
                    'ListSize', [200 50],...
                    'OKString', 'Choose',...
                    'CancelString', 'Do nothing',...
                    'ListString',options);
                
                    if ~v
                       return; 
                    end
                    if s == 1
                       obj.create_new_lvltwo_segment(mouse_pos); 
                    elseif s == 2
                       obj.move_lvl2_segment(mouse_pos); 
                    end
                    
                else
                    obj.create_new_lvltwo_segment(mouse_pos);
                end
            end
        end
        
        %% create_new_lvltwo_segment
        % creates a new Level 2 set
        function create_new_lvltwo_segment(obj, pos)
            
            % determine wether there is already a level 2 set and set the
            % number of the new level 2 set
            log = strncmp(fieldnames(obj.audio),'lvl_two',7);            
            if sum(log) > 0
                nr = length(obj.audio.lvl_two) + 1;
            else
                nr = 1;
            end
               
            Onset = obj.sample_in_plot_to_time(pos);
            Offset = Onset + 15*10^7;
            obj.audio.lvl_two(nr).Onset = Onset;
            obj.audio.lvl_two(nr).Offset = Offset;
            obj.audio.lvl_two(nr).Memo = '';
            offset_plot = obj.time_to_sample_in_plot(Offset);
            obj.audio.lvl_two(nr).OnsetLineObject = line([pos pos],[-.97 .97],'Parent',obj.handles.time_cursor_axes,'Color',[obj.red .5],'Linewidth',2,'Marker','>');
            obj.audio.lvl_two(nr).OnsetLineObject.UserData = struct('Nr',nr,'Type','Onset');
            obj.audio.lvl_two(nr).OffsetLineObject = line([offset_plot offset_plot],[-.97 .97],'Parent',obj.handles.time_cursor_axes,'Color',[obj.red .5],'Linewidth',2,'Marker','<');
            obj.audio.lvl_two(nr).OffsetLineObject.UserData = struct('Nr',nr,'Type','Offset');
            set(obj.audio.lvl_two(nr).OffsetLineObject, 'ButtonDownFcn', @obj.callback_time_axes_beyond);
            set(obj.audio.lvl_two(nr).OnsetLineObject, 'ButtonDownFcn', @obj.callback_time_axes_beyond);
            obj.audio.lvl_two(nr).Deleted = false;         
        end
        
        %% move_lvl2_segment
        % moves a existing Level 2 Set
        function move_lvl2_segment(obj, pos)
            number_of_lvl2_segments = length(obj.audio.lvl_two);
            options = struct('str',{});
            for ii=1:number_of_lvl2_segments
                memo = char(obj.audio.lvl_two(ii).Memo);
                a = regexp(memo, '\n');
                if ~isempty(a)
                    memo = memo(1:a-1);
                end
                options(ii).str = ['Segment ',num2str(ii),': ',memo];
            end
            options = {options.str}';
            [lvl_nr,v] = listdlg('PromptString','Select the set you want to move:',...
                'SelectionMode','single',...
                'ListSize', [200 50],...
                'OKString', 'Choose',...
                'CancelString', 'Do nothing',...
                'ListString',options);
            if ~v
                return;
            end
            
            options = {'Set the Start';'Set the End'};
            [s,v] = listdlg('PromptString',['Setting the Start or the End of Set ',num2str(lvl_nr),':'],...
                'SelectionMode','single',...
                'ListSize', [250 50],...
                'OKString', 'Choose',...
                'CancelString', 'Do nothing',...
                'ListString',options);
            if ~v
                return;
            end
            
            if s == 1
                type = 'Onset';
            elseif s == 2
                type = 'Offset';
            end
            
            obj.audio.lvl_two(lvl_nr).(type) = obj.sample_in_plot_to_time(pos);
            obj.audio.lvl_two(lvl_nr).([type,'LineObject']).XData = [pos pos];                  
        end
        
        %% set_dragging_lvltwo_line
        function set_dragging_lvltwo_line(obj, hObject, eventData)
           % remove first WindowButtonMotionFcn which determine the cursor
           % object
           iptremovecallback(obj.handles.fig, 'WindowButtonMotionFcn', obj.h_window_motion);
           
           % set a new function for WindowButtonMotionFcn, so the position
           % of the grabbed bound will be updated if mouse is moved
           obj.h_window_motion_grab = iptaddcallback(...
                    obj.handles.fig,...
                    'WindowButtonMotionFcn',...
                    {@obj.drag_lvltwo_line, hObject});
                
           % set callback what should happen if mouse key will be released     
           obj.h_window_button_up = iptaddcallback(...
                    obj.handles.fig,...
                    'WindowButtonUpFcn',...
                    {@obj.release_dragging_lvltwo_line, hObject});
           
            nr = hObject.UserData.Nr;
            start_pt = obj.time_to_sample_in_plot(obj.audio.lvl_two(nr).Onset);
            end_pt = obj.time_to_sample_in_plot(obj.audio.lvl_two(nr).Offset);
            obj.handles.tmp_line = line([start_pt end_pt],[0 0],'Parent',obj.handles.time_cursor_axes,'Color',[obj.cyan .3],'Linewidth',100);
        end
        
        %% drag_lvltwo_line
        function drag_lvltwo_line(obj, hObject, eventData, hLine)
            mouse_pos = get(obj.handles.time_cursor_axes, 'currentpoint');
            
            lvl_nr = hLine.UserData.Nr;
            type = hLine.UserData.Type;
            
            if strcmp(type,'Onset')
               other_type = 'Offset'; 
               idx = 1;
            else
               other_type = 'Onset';
               idx = 2;
            end
            
            range = 20;
            new_pos = mouse_pos(1,1);
            for ii=1:length(obj.audio.lvl_two)
                if ii~=lvl_nr
                   
                   diff = abs(obj.time_to_sample_in_plot(obj.audio.lvl_two(ii).(other_type)) - mouse_pos(1,1));
                   if diff < range
                       if strcmp(other_type,'Offset')
                           new_pos = obj.time_to_sample_in_plot(obj.audio.lvl_two(ii).(other_type) - 1);
                       elseif strcmp(other_type,'Onset')
                           new_pos = obj.time_to_sample_in_plot(obj.audio.lvl_two(ii).(other_type) + 1);
                       end
                       break;
                   end
                elseif ii==lvl_nr
                    diff = obj.time_to_sample_in_plot(obj.audio.lvl_two(ii).(other_type)) - mouse_pos(1,1);
                    if diff < 0 && strcmp(other_type,'Offset')
                        new_pos = obj.time_to_sample_in_plot(obj.audio.lvl_two(ii).(other_type)) - 50;
                    elseif diff > 0 && strcmp(other_type,'Onset')
                        new_pos = obj.time_to_sample_in_plot(obj.audio.lvl_two(ii).(other_type)) + 50;
                    end
                    
                end
                
            end
            
            if new_pos < 1
                new_pos = 1;
            elseif new_pos > obj.var.audio_info.TotalSamples/obj.var.qp
                new_pos = obj.var.audio_info.TotalSamples/obj.var.qp;
            end
            % update XData of the Level 2 Line:
            hLine.XData = [new_pos new_pos];
            
                
            obj.handles.tmp_line.XData(idx) = new_pos;
        end
        
        %% release_dragging_lvltwo_line
        function release_dragging_lvltwo_line(obj, hObject, eventData, hLine)
            % remove callbacks
            iptremovecallback(obj.handles.fig, 'WindowButtonMotionFcn', obj.h_window_motion_grab);
            iptremovecallback(obj.handles.fig, 'WindowButtonUpFcn', obj.h_window_button_up);
            
            % add default callback
            obj.h_window_motion = iptaddcallback(...
               obj.handles.fig,...
               'WindowButtonMotionFcn',...
               @obj.drag_and_drop);
           
           % update data
           lvltwo_nr = hLine.UserData.Nr;
           NewSet = obj.sample_in_plot_to_time(hLine.XData(1));
           obj.audio.lvl_two(lvltwo_nr).([hLine.UserData.Type]) = NewSet;
           
           delete(obj.handles.tmp_line);
        end
        
        %% show_info
        % shows information about the current selected Object (VAD, Level 2
        % Set)
        function show_info(obj)
            % show info of clicked vad
            if obj.var.vad_tagged
               obj.handles.annotation_jtext_pane.setEditable(true);
               obj.handles.annotation_jtext_pane.setEnabled(true);
               obj.handles.comment_jtext_pane.setEditable(true);
               obj.handles.comment_jtext_pane.setEnabled(true);
               comment = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Memo;
               code = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Code;
               obj.handles.comment_jtext_pane.setText(comment);
               obj.handles.annotation_jtext_pane.setText(code);
               if ~obj.handles.custom_keyboard_checkbox.Value
                   obj.h_annotation_panel.grabFocus();
                   txt_len = length(char(obj.handles.annotation_jtext_pane.getText));
                   obj.handles.annotation_jtext_pane.setCaretPosition(txt_len);
               end
               invalid_code = obj.is_code_invalid();
               
               if invalid_code
                   obj.handles.annotation_jtext_pane.setBackground(java.awt.Color(0.8627, 0.1961, 0.1843));
               else
                   obj.handles.annotation_jtext_pane.setBackground(java.awt.Color(1, 1, 1));
               end
            % show info of clicked Level2 Set
            elseif obj.var.lvl2_nr
               obj.handles.comment_jtext_pane.setEditable(true);
               obj.handles.comment_jtext_pane.setEnabled(true);
               comment = obj.audio.lvl_two(obj.var.lvl2_nr).Memo;
               obj.handles.comment_jtext_pane.setText(comment);
               str = ['Set ',num2str(obj.var.lvl2_nr)];
               obj.handles.annotation_jtext_pane.setText(str);
            % if nothing is clicked show nothing
            else
               obj.handles.annotation_jtext_pane.setBackground(java.awt.Color(.95, .95, .95));
               obj.handles.annotation_jtext_pane.setEditable(false);
               obj.handles.annotation_jtext_pane.setEnabled(false);
               obj.handles.comment_jtext_pane.setEditable(false);
               obj.handles.comment_jtext_pane.setEnabled(false);
               obj.handles.comment_jtext_pane.setText('');
               obj.handles.annotation_jtext_pane.setText('');  
            end       
        end
        
        %% callback_annotation_focuslost
        % Doesn't have any function yet
        function callback_annotation_focuslost(obj, hObject, eventData)
            
        end
        
        %% is_code_invalid
        % determine whether the current code is within the current loaded
        % key or not.
        function invalid_code = is_code_invalid(obj)
            code = char(obj.handles.annotation_jtext_pane.getText);
            code = obj.split_codestring_into_cell(code);
            code = code(~cellfun('isempty',code));
            
            invalid_code = false;
            for kk=1:length(code)
                log = strncmpi(obj.var.lookuptable(:,2),char(code(kk)),length(char(code(kk))));
                if sum(log) < 1
                    invalid_code = true;
                    break;
                else
                    if sum(log) > 1
                        codes = obj.var.lookuptable(log,2);
                        for jj=1:length(codes)
                            invalid_code = true;
                            if strcmp(codes(jj),code(kk))
                                invalid_code = false;
                                break;
                            end
                        end
                    end
                end
            end
        end
        
        %% callback_annotation_keytyping
        % executes when there is an input within the annotation input field
        function callback_annotation_keytyping(obj, hObject, eventData)
            % If Tab is typed:
            if eventData.getKeyCode == 9
                code = char(obj.handles.annotation_jtext_pane.getText);
                obj.handles.annotation_jtext_pane.setText(code(1:end-1));
                obj.h_comment_panel.grabFocus();
            % If Enter is typed:    
            elseif eventData.getKeyCode == 10
                    code = char(obj.handles.annotation_jtext_pane.getText);
                    obj.handles.annotation_jtext_pane.setText(code(1:end-1));
                    jFig = get(handle(obj.handles.fig), 'JavaFrame');
                    window = jFig.fHG2Client.getWindow;
                    window.transferFocus;
            % If F7 is typed:    
            elseif eventData.getKeyCode == 118
                a.EventName = 'WindowKeyRelease';
                obj.callback_play(obj.handles.play_button, a);
                return;
            % If F12 is typed:    
            elseif eventData.getKeyCode == 123
                obj.var.last_sample_plot = obj.handles.timer_cursor.XData(1);
                obj.play_vad_segment(obj.handles.play_button, eventData);
                return;
            end
            
            code = obj.handles.annotation_jtext_pane.getText;
            obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Code = code;
            obj.update_text_plot();
            invalid_code = obj.is_code_invalid();
            
            if invalid_code
                obj.handles.annotation_jtext_pane.setBackground(java.awt.Color(0.8627, 0.1961, 0.1843));
            else
                obj.handles.annotation_jtext_pane.setBackground(java.awt.Color(1, 1, 1));
            end
            
            
        end
        
        %% callback_comment_keytyping
        % executes when there is an input within the comment input field
        function callback_comment_keytyping(obj, hObject, eventData)
            % If Enter is typed:    
            if eventData.getKeyCode == 10
                    code = char(obj.handles.annotation_jtext_pane.getText);
                    obj.handles.annotation_jtext_pane.setText(code(1:end-1));
                    jFig = get(handle(obj.handles.fig), 'JavaFrame');
                    window = jFig.fHG2Client.getWindow;
                    window.transferFocus;
            end
            
            % not in use:
            if eventData.isShiftDown && eventData.isControlDown && eventData.getKeyCode == 72
                obj.callback_custom_keyboard(eventData);
            end
            
            comment = obj.handles.comment_jtext_pane.getText;
            
            if obj.var.vad_tagged
                obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Memo = comment;
                obj.update_text_plot();
            elseif obj.var.lvl2_nr
                obj.audio.lvl_two(obj.var.lvl2_nr).Memo = comment;
            end
        end
                
        %% callback_export_to_excel
        % saves the current state within a excel file
        function callback_export_to_excel(obj, hObject, eventData)
            if obj.var.audio_loaded
                set(obj.handles.save_button,'BackgroundColor', obj.red);
                set(obj.handles.save_button,'ShadowColor', obj.red);
                set(obj.handles.save_button,'HighlightColor', obj.red);
                drawnow;
                
                % Get all VADs and sort them in order of time
                Onsets = [];
                vad = [];
                log = strncmp(fieldnames(obj.audio.data),'vad',3);
                if sum(log) > 0
                    for ii=1:length(obj.audio.data)
                        if ~isempty(obj.audio.data(ii).vad)
                            Onsets = [Onsets, obj.audio.data(ii).vad.Onset];
                            vad = [vad, obj.audio.data(ii).vad];
                        end
                    end
                end
                
                % Excel Header
                excel_head(1) = cellstr('Level');
                excel_head(2) = cellstr('Onset');
                excel_head(3) = cellstr('Offset');
                excel_head(4) = cellstr('Memo');
                excel_head(5) = cellstr('Sprecher');
                excel = cell.empty(0,5);
                
                if ~isempty(Onsets)

                    % Remove deleted VADs
                    deleted = [vad.Deleted];
                    vad = vad(~deleted);            
                    
                    for ii=1:length(vad)
                        excel(ii,1) = num2cell(3);
                        excel(ii,2) = num2cell(vad(ii).Onset);
                        excel(ii,3) = num2cell(vad(ii).Offset);
                        excel(ii,4) = cellstr(char(vad(ii).Memo));
                        excel(ii,5) = cellstr(obj.handles.data(vad(ii).Object.UserData.ID(1)).speaker_name.String);
                        codechar = char(vad(ii).Code);
                        
                        % Split Code String in several Strings if the whole code
                        % consists of more than one code.
                        code = obj.split_codestring_into_cell(codechar);
                        
                        % Record every code to the right code class. If
                        % corresponding code class doesn't exist yet, add to excel header
                        for kk=1:length(code)
                            if ~isempty(char(code(kk)))
                                log = strncmpi(obj.var.lookuptable(:,2),char(code(kk)),length(char(code(kk))));
                                codeclass = obj.var.lookuptable(log,3);
                                jj = 1;
                                
                                % do this if two codes are very similar
                                if sum(log) > 1
                                    codes = obj.var.lookuptable(log,2);
                                    for jj=1:length(codes)
                                        if strcmp(codes(jj),code(kk))
                                            break;
                                        end
                                    end
                                end
                                
                                % If code doesn't belong to any codeclass
                                if isempty(codeclass)
                                    codeclass = 'Unknown';
                                else
                                    codeclass = codeclass(jj);
                                end
                                
                                % check wether there already exist a column
                                % with this codeclass and determine the index of it
                                % otherwise create a new column
                                idx = strncmpi(excel_head(:),char(codeclass),length(char(codeclass)));
                                if sum(idx)
                                    if ~isempty(excel{ii,idx})
                                        excel(ii,idx) = cellstr([excel{ii,idx},'; ',char(code(kk))]);
                                    else
                                        excel(ii,idx) = cellstr(code(kk));
                                    end
                                else
                                    excel_head(end+1) = cellstr(codeclass);
                                    excel(ii,size(excel_head,2)) = cellstr(code(kk));
                                end
                            end
                        end
                    end
                end
                
                % Collect all Level 2 Sets:
                log = strncmp(fieldnames(obj.audio),'lvl_two',7);
                if sum(log) > 0
                    for jj=1:length(obj.audio.lvl_two)
                        ii = size(excel,1) + 1;
                        excel(ii,1) = num2cell(2);
                        excel(ii,2) = num2cell(obj.audio.lvl_two(jj).Onset);
                        excel(ii,3) = num2cell(obj.audio.lvl_two(jj).Offset);
                        excel(ii,4) = cellstr(char(obj.audio.lvl_two(jj).Memo));
                    end
                end
                
                % Add Level 1:
                ii = size(excel,1) + 1;
                excel(ii,1) = num2cell(1);
                excel(ii,2) = num2cell(0);
                excel(ii,3) = num2cell(0);
                excel(ii,4) = cellstr(char(obj.handles.group_name.String)); 
                
                % Sort first by Levels:
                [~,I] = sort(cell2mat(excel(:,1)));
                excel = excel(I,:);
                
                % Sort by Onset:
                [~,I] = sort(cell2mat(excel(:,2)));
                excel = excel(I,:);
                
                % Add Header to Excel:
                excel = [excel_head; excel];
                
                % if callback is executed by autosave timer
                if strcmp(hObject.Tag,'Autosave')
                    file = dir(fullfile(obj.var.dbdir, 'Autosave.xlsx'));
                    if ~isempty(file)
                        delete([obj.var.dbdir, filesep, 'Autosave.xlsx']);
                    end
                    xlswrite([obj.var.dbdir, filesep, 'Autosave.xlsx'],excel);
                else
                    % Determine wether this project is already loaded by a
                    % excel and make a filename proposal
                    if ~isempty(obj.var.excel_src)
                        filename = obj.var.excel_src.name;
                    else
                        filename = 'newfile.xlsx';
                    end
                    [filename,pathname,idx] = uiputfile({'*.xlsx','All Excel Files'},'Save Excel',...
                        [obj.var.dbdir, filesep, filename]);
                    
                    if idx
                        file = dir(fullfile(pathname, filename));
                        if ~isempty(file)
                            delete([pathname, filesep, filename]);
                        end
                        xlswrite([pathname, filesep, filename],excel);
                        excel_opt = obj.convert_excel_to_old_version(excel);
                        xlswrite([pathname, filesep, filename(1:end-5),'_oldversion.xlsx'],excel_opt);
                    end
                end
                
                set(obj.handles.save_button,'BackgroundColor', obj.blue);
                set(obj.handles.save_button,'ShadowColor', obj.blue);
                set(obj.handles.save_button,'HighlightColor', obj.blue);
            end
        end
        
        %% set_dragging_vad
        function set_dragging_vad(obj)
            mouse_pos = get(obj.handles.soundwave_axes(obj.var.vad_tagged(1)), 'currentpoint');  
            lower_bound = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData(1);
            higher_bound = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData(2);
           
           % compute offset of bound position and
           % mouse position
           obj.var.dx_low = mouse_pos(1,1) - lower_bound;
           obj.var.dx_high = mouse_pos(1,1) - higher_bound;
           
           % remove first WindowButtonMotionFcn which determine the cursor
           % object
           iptremovecallback(obj.handles.fig, 'WindowButtonMotionFcn', obj.h_window_motion);
           
           % set a new function for WindowButtonMotionFcn, so the position
           % of the grabbed bound will be updated if mouse is moved
           obj.h_window_motion_grab = iptaddcallback(...
                    obj.handles.fig,...
                    'WindowButtonMotionFcn',...
                    @obj.drag_vad);
           
           % set callback what should happen if mouse key will be released     
           obj.h_window_button_up = iptaddcallback(...
                    obj.handles.fig,...
                    'WindowButtonUpFcn',...
                    @obj.release_dragging_vad);   
        end
        
        %% drag lower or higher bound of a vad
        function drag_vad(obj, hObject, eventData)
            mouse_pos = get(obj.handles.soundwave_axes(obj.var.vad_tagged(1)), 'currentpoint');
            xdata = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData;
            if strcmp(obj.handles.fig.Pointer,'left')
                x_new = mouse_pos(1,1) - obj.var.dx_low;
                xdata(1) = x_new; xdata(4) = x_new;
                obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData = xdata;
                obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Onset = obj.sample_in_plot_to_time(x_new);
                obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject.Position(1) = x_new;
            elseif strcmp(obj.handles.fig.Pointer,'right')
                x_new = mouse_pos(1,1) - obj.var.dx_high;
                xdata(2:3) = x_new;
                obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData = xdata;
                obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Offset = obj.sample_in_plot_to_time(x_new);
            end
            obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).PlotData = xdata;
        end
        
        %% release_dragging_vad
        function release_dragging_vad(obj, hObject, eventData) 
            % remove callbacks
            iptremovecallback(obj.handles.fig, 'WindowButtonMotionFcn', obj.h_window_motion_grab);
            iptremovecallback(obj.handles.fig, 'WindowButtonUpFcn', obj.h_window_button_up);
            
            % add default callback
            obj.h_window_motion = iptaddcallback(...
               obj.handles.fig,...
               'WindowButtonMotionFcn',...
               @obj.drag_and_drop);
           
           Onset = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Onset;
           Offset = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Offset;
           
           % switches Onset and Offset if necessary
           if Onset > Offset
               obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Onset = Offset;
               obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Offset = Onset;
               obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject.Position(1)...
                   = obj.time_to_sample_in_plot(Offset);
               xdata = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData;
               new(1) = xdata(2); new(2) = xdata(1); new(3) = xdata(4); new(4) = xdata(3);
               obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData = new;
           end
           obj.sort_vads(obj.var.vad_tagged(1), obj.var.vad_tagged(2));
        end
        
        %% grab
        % function to navigate within the soundwave axes ( just preparing
        % the callbacks)
        function grab(obj, hObject, eventData)
            setfigptr('closedhand', obj.handles.fig);
            iptremovecallback(obj.handles.fig, 'WindowButtonMotionFcn', obj.h_window_motion);
            mouse_pos = get(obj.handles.soundwave_axes(1), 'currentpoint');
            if strcmp(obj.handles.fig.SelectionType,'normal')
                
                % compute offset (corner bottom left) and
                % mouse position
                dx = mouse_pos(1,1);
                
                % set a new function for WindowButtonMotionFcn
                obj.h_window_motion_grab = iptaddcallback(...
                    obj.handles.fig,...
                    'WindowButtonMotionFcn',...
                    {@obj.drag, obj.handles.soundwave_axes(1), dx});
                
                % set callback what should happen if mouse key will be released
                obj.h_window_button_up = iptaddcallback(...
                    obj.handles.fig,...
                    'WindowButtonUpFcn',...
                    @obj.release);
            end
        end
        
        %% drag
        % function to navigate within the soundwave axes
        function drag(obj, hObject, eventData, axes_object, dx)
            mouse_pos = get(axes_object, 'currentpoint');
            shift_x = mouse_pos(1,1) - dx;
            
            % avoids to navigate beyond time borders
            if obj.handles.soundwave_axes(1).XLim(1)-shift_x < 1
                xlim_min = 1;
                xlim_max = obj.var.q_reference/obj.var.qp*obj.show_seconds;
            elseif obj.handles.soundwave_axes(1).XLim(2)-shift_x > obj.var.audio_info.TotalSamples/obj.var.qp
                xlim_min = obj.var.audio_info.TotalSamples/obj.var.qp - obj.var.q_reference/obj.var.qp*obj.show_seconds;
                xlim_max = obj.var.audio_info.TotalSamples/obj.var.qp;
            else
                xlim_min = obj.handles.soundwave_axes(1).XLim(1)-shift_x;
                xlim_max = obj.handles.soundwave_axes(1).XLim(2)-shift_x;
            end
            
            for ii=1:length(obj.audio.speaker)
                obj.handles.soundwave_axes(ii).XLim = [xlim_min xlim_max];
            end
            obj.handles.time_cursor_axes.XLim = [xlim_min xlim_max];
            
            CurrentTime = datevec(round(obj.handles.timer_cursor.XData(1) *obj.var.qp + obj.var.delay_in_sample)/obj.audio.reference.SampleRate/86400);
            obj.handles.current_time_str.String = sprintf('%02.0f:%02.0f:%02.0f:%03.0f', CurrentTime(4), CurrentTime(5), fix(CurrentTime(6)), fix((CurrentTime(6)-fix(CurrentTime(6)))*1000) );
            obj.update_time_slider();
        end
        
        %% release
        function release(obj, hObject, eventData)
            % remove callbacks
            iptremovecallback(obj.handles.fig, 'WindowButtonMotionFcn', obj.h_window_motion_grab);
            iptremovecallback(obj.handles.fig, 'WindowButtonUpFcn', obj.h_window_button_up);
            
            obj.h_window_motion = iptaddcallback(...
               obj.handles.fig,...
               'WindowButtonMotionFcn',...
               @obj.drag_and_drop);
            
            obj.set_reference_new_with_timecursor();
        end
        
        %% callback_clicked_toggle
        % executes if toolbar is clicked
        function callback_clicked_toggle(obj, hObject, eventData)
            for ii=1:length(hObject.Parent.Children)
                % switch all tools off except the desired one
                if ~strcmp(hObject.Tag, hObject.Parent.Children(ii).Tag)
                    hObject.Parent.Children(ii).State = 'off';
                else
                    hObject.Parent.Children(ii).State = 'on';
                end
            end
            % change cursor mode
            obj.cursor_mode = hObject.Tag;
            
            % untag vad if necessary and if the tool switch to 'search' or
            % 'leveltwo'
            if obj.var.vad_tagged
                if strcmp(hObject.Tag, 'search') || strcmp(hObject.Tag, 'leveltwo')
                    if isempty(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject.String)
                        obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.yellow;
                    else
                        obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.green;
                    end
                    obj.var.vad_tagged = [0 0];
                    obj.show_info();
                end
            end
            if obj.var.lvl2_nr
                obj.var.lvl2_nr = 0;
                obj.show_info();
            end
            
            % just update the mouse cursor
            obj.drag_and_drop(hObject, eventData);
        end
        
        %% callback_editing_label
        % for changing the string and avoids line breaks
        function callback_editing_label(obj, hObject, eventData)
            hObject.Editing = 'on';
            while strcmp(hObject.Editing,'on')
               pause(0.1)
            end
            if size(hObject.String,1) > 1
                str = cell(0);
                for ii = 1:size(hObject.String,1)
                    str(ii) = {strtrim(hObject.String(ii,:))};
                end
                hObject.String = strjoin(str);
            end
        end
        
        %% callback_load
        function callback_load(obj, hObject, eventData)
            set(obj.handles.load_button,'BackgroundColor', obj.red);
            set(obj.handles.load_button,'ShadowColor', obj.red);
            set(obj.handles.load_button,'HighlightColor', obj.red);
            drawnow;
                   
            ID = fopen([pwd,filesep,'tmp'],'r');
            folder = [];
            if ID ~= -1
                folder = fscanf(ID,'%c');
                fclose(ID);
            end
            if isempty(folder)
                folder = [pwd,filesep];
            else
                folder = [folder,filesep,'..',filesep];
            end
            obj.var.dbdir = uigetdir(folder, 'Select an Directory');
            
            if ~obj.var.dbdir
                set(obj.handles.load_button,'BackgroundColor', obj.blue);
                set(obj.handles.load_button,'ShadowColor', obj.blue);
                set(obj.handles.load_button,'HighlightColor', obj.blue);
                return;
            end
            
            ID = fopen([pwd,filesep,'tmp'],'w');
            fprintf(ID,'%s',obj.var.dbdir);
            fclose(ID);
            
            % if a project is already loaded reset everything
            if obj.var.audio_loaded
                obj.reset_current_state();
            end
            
            
            if exist([obj.var.dbdir, filesep, obj.name_of_tmp_folder], 'dir') == 0,
                % dir not existing so try to create it
                mkdir([obj.var.dbdir, filesep, obj.name_of_tmp_folder]);
            end
            
            obj.var.audio_src = [dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, '*_' num2str(obj.var.goal_fs/1000) 'kHz.wav']));...
                                  dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, '*_' num2str(obj.var.goal_fs/1000) 'kHz.wma']));...
                                  dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, '*_' num2str(obj.var.goal_fs/1000) 'kHz.mp3']))];
             
            block_msg_cleanup = obj.set_info_text_at_loading();                
            if isempty(obj.var.audio_src)
                obj.var.audio_src = [dir(fullfile(obj.var.dbdir, '*.wav'));...
                                  dir(fullfile(obj.var.dbdir, '*.wma'));...
                                  dir(fullfile(obj.var.dbdir, '*.mp3'))];

                obj.resample_signals();
            end
                             
                             
            obj.var.excel_src = dir(fullfile(obj.var.dbdir, '*.xlsx'));
            
            
            
            obj.init_videoreader();
            
            
            if isempty(obj.var.audio_src) && ~isempty(obj.var.video_src)
                answer = '';
                while ~isnumeric(answer) || answer > 8
                    prompt = 'There are no Audio Files! That''s why the audio of the video will be used. Choose a number of speakers(1-8):';
                    dlg_title = 'Number of Speakers';
                    num_lines = 1;
                    def = {'3'};
                    answer = inputdlg(prompt,dlg_title,num_lines,def);
                    
                    if isempty(answer)
                        return;
                    end
                    try
                        answer = str2num(cell2mat(answer));
                    catch
                    end
                end
                obj.var.no_audio = true;
                obj.var.audio_src(1:answer) = obj.var.video_src(1);
            end
            
            obj.find_delay();
            obj.init_audioread(1);
            
            for ii=1:length(obj.audio.speaker)
                obj.audio.speaker(ii).UserData.Muted = false;
                obj.audio.speaker(ii).UserData.Solo = false;
                obj.audio.speaker(ii).UserData.On = true;
            end
            
            % create reference audio
            obj.audio.reference = audioplayer(zeros(length(obj.audio.data(1).samples_plot),1),obj.var.fs,8);
            set(obj.audio.reference, 'TimerFcn', @obj.timefcn, 'StopFcn', @obj.stopfcn, 'StartFcn', @obj.timefcn);
            obj.audio.reference.TimerPeriod = .01;
            
            obj.init_soundwave_plot();
            obj.init_reference_plot();
            obj.create_init_lvl2_segment();
            obj.init_mute_panels();
            obj.init_solo_panels();
            obj.init_time_strings();
            obj.init_time_slider();
            obj.init_autosave_timer();
            obj.init_time_on_axes();
              
            obj.var.audio_loaded = true;
            
            set(obj.handles.play_button,'BackgroundColor', obj.blue);
            set(obj.handles.play_button,'ShadowColor', obj.blue);
            set(obj.handles.play_button,'HighlightColor', obj.blue);
            
            set(obj.handles.save_button,'BackgroundColor', obj.blue);
            set(obj.handles.save_button,'ShadowColor', obj.blue);
            set(obj.handles.save_button,'HighlightColor', obj.blue);
            
            set(obj.handles.load_button,'BackgroundColor', obj.blue);
            set(obj.handles.load_button,'ShadowColor', obj.blue);
            set(obj.handles.load_button,'HighlightColor', obj.blue);
            
            clear block_msg_cleanup;
        end
        
        %% 
        function resample_signals(obj)
            if ~isempty(obj.var.audio_src)
                audio_info = audioinfo([obj.var.dbdir,filesep,obj.var.audio_src(1).name]);
                
                if audio_info.SampleRate ~= obj.var.goal_fs
                    [n,d] = rat(obj.var.goal_fs/audio_info.SampleRate);
                   
                    for ii=1:length(obj.var.audio_src)
                        obj.update_msg_block(['Resampling of the signals is running. This must be done once! '...
                            'Loading file ',num2str(ii),'/',num2str(length(obj.var.audio_src)), '.']);
                        
                        x = audioread([obj.var.dbdir,filesep,obj.var.audio_src(ii).name]);
                        
                        obj.update_msg_block(['Resampling of the signals is running. This must be done once! '...
                            'Resampling file ',num2str(ii),'/',num2str(length(obj.var.audio_src)), '.']);
                        y = resample(x,n,d);
                        clear x;
                        
                        obj.update_msg_block(['Resampling of the signals is running. This must be done once! '...
                            'Saving file ',num2str(ii),'/',num2str(length(obj.var.audio_src)), '.']);
                        audiowrite([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep ,obj.var.audio_src(ii).name(1:end-4) '_' num2str(obj.var.goal_fs/1000) 'kHz.wav'],y,obj.var.goal_fs);
                        clear y;
                    end
                    obj.var.audio_src = [dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, '*_' num2str(obj.var.goal_fs/1000) 'kHz.wav']));...
                                         dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, '*_' num2str(obj.var.goal_fs/1000) 'kHz.wma']));...
                                         dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep '*_' num2str(obj.var.goal_fs/1000) 'kHz.mp3']))];
                end
            end
        end
               
        %% create_init_lvl2_segment
        function create_init_lvl2_segment(obj)
            
            % determine wether there is already a level 2. If not create
            % the first one.
            log = strncmp(fieldnames(obj.audio),'lvl_two',7);            
            if sum(log) > 0
                return;
            end
            obj.create_new_lvltwo_segment(1);
            
        end
    
        %% reset_current_state
        function reset_current_state(obj)
            obj.var.audio_loaded = false;
            for ii=1:length(obj.audio.speaker)
                delete(obj.handles.data(ii).speaker_name);
            end
            delete(obj.audio.speaker);
            delete(obj.audio.reference);
            delete(obj.handles.soundwave_axes);
            delete(obj.handles.time_cursor_axes);
            delete(obj.handles.group_name_place);
            delete(obj.handles.group_name);
            for ii=1:8
                set(obj.handles.mute_panel(ii),'ButtonDownFcn', '');
                set(obj.handles.mute_panel(ii),'BackgroundColor', obj.base01);
                set(obj.handles.mute_panel(ii),'HighlightColor', obj.base01);
                set(obj.handles.mute_panel(ii),'ShadowColor', obj.base01);
                set(obj.handles.solo_panel(ii),'ButtonDownFcn', '');
                set(obj.handles.solo_panel(ii),'BackgroundColor', obj.base01);
                set(obj.handles.solo_panel(ii),'HighlightColor', obj.base01);
                set(obj.handles.solo_panel(ii),'ShadowColor', obj.base01);
            end
            set(obj.handles.vad_button,'BackgroundColor', obj.darkergrey);
            set(obj.handles.vad_button,'HighlightColor', obj.darkergrey);
            set(obj.handles.vad_button,'ShadowColor', obj.darkergrey);
            obj.audio = [];
            obj.init_var();
            obj.show_info();
        end
        
        %% callback_play
        function callback_play(obj, hObject, eventData)
            if obj.var.audio_loaded
                if ~isempty(eventData)
                    if strcmp(eventData.EventName, 'ButtonDown')...
                            || strcmp(eventData.EventName, 'WindowKeyRelease')
                        obj.var.is_playing = ~obj.var.is_playing;
                    end
                end
                
                obj.play(hObject, eventData);
            end
        end
        
        %% play
        function play(obj, hObject, eventData)
            if strcmp(hObject.Title,'Play');
                stop(obj.handles.autosave_timer);
                obj.set_panel_button(hObject,eventData, 'Pause', obj.red);
                play(obj.audio.reference, [obj.var.start_sample obj.audio.reference.TotalSamples]);
                for ii=1:length(obj.audio.speaker)
                    if obj.audio.speaker(ii).UserData.On
                        play(obj.audio.speaker(ii), [obj.audio.reference.CurrentSample ...
                            obj.audio.speaker(ii).TotalSamples]);
                    end
                end
            elseif strcmp(hObject.Title,'Pause')
                obj.audio.reference.pause;
                for ii=1:length(obj.audio.speaker)
                    obj.audio.speaker(ii).pause;
                end
                obj.set_panel_button(hObject,eventData, 'Play', obj.blue);
                if strcmp(obj.handles.autosave_timer.Running,'off')
                    start(obj.handles.autosave_timer);
                end
            end
            
            obj.update_soundwave_plot();
            obj.update_time_string();
        end

        %% play_vad_segment
        function play_vad_segment(obj, hObject, eventData)
            if obj.var.vad_tagged
                speaker = obj.var.vad_tagged(1);
                vad_nr = obj.var.vad_tagged(2);
                
                % stop already playing vad segment
                if obj.var.vad_is_playing
                    obj.audio.reference.pause;
                    obj.audio.speaker(speaker).pause;
                end
                
                % determine start and end of segment considering current
                % buffered audio
                start_sample = round(obj.time_to_sample_in_plot(obj.audio.data(speaker).vad(vad_nr).Onset) * obj.var.qp);
                end_sample = round(obj.time_to_sample_in_plot(obj.audio.data(speaker).vad(vad_nr).Offset) * obj.var.qp);
                if (end_sample-obj.var.offset) > obj.audio.reference.TotalSamples
                    end_sample = obj.audio.reference.TotalSamples;
                else
                    end_sample = end_sample-obj.var.offset;
                end
                obj.set_panel_button(obj.handles.play_button, eventData, 'Pause', obj.red);
                play(obj.audio.reference, [start_sample-obj.var.offset end_sample]);
                play(obj.audio.speaker(speaker), [start_sample-obj.var.offset end_sample]);
                obj.var.vad_is_playing = true;
            end
        end
        
        %% set_panel_button
        function set_panel_button(obj, hObject, eventData, string, color)
                set(obj.handles.play_button,'Title',string);
                set(obj.handles.play_button,'BackgroundColor', color);
                set(obj.handles.play_button,'ShadowColor', color);
                set(obj.handles.play_button,'HighlightColor', color); 
                drawnow;
        end
        
        %% callback_mute
        function callback_mute(obj, hObject, eventData)
            if hObject.BackgroundColor == obj.blue
                obj.audio.speaker(hObject.UserData.Channel).pause
                obj.audio.speaker(hObject.UserData.Channel).UserData.Muted = true;
                obj.audio.speaker(hObject.UserData.Channel).UserData.On = false;
                obj.handles.soundwave_axes(hObject.UserData.Channel).Color = [.7 .7 .7];
                set(hObject,'BackgroundColor', obj.red);
                set(hObject,'HighlightColor', obj.red);
                set(hObject,'ShadowColor', obj.red);
            elseif hObject.BackgroundColor == obj.red    
                obj.audio.speaker(hObject.UserData.Channel).UserData.Muted = false;
                obj.update_playing_speakers();
                if obj.audio.reference.isplaying && obj.audio.speaker(hObject.UserData.Channel).UserData.On
                    play(obj.audio.speaker(hObject.UserData.Channel),[obj.audio.reference.CurrentSample ...
                        obj.audio.speaker(hObject.UserData.Channel).TotalSamples]);
                end
                set(hObject,'BackgroundColor', obj.blue);
                set(hObject,'HighlightColor', obj.blue);
                set(hObject,'ShadowColor', obj.blue);
            end
        end

        %% callback_solo
        function callback_solo(obj, hObject, ~)
            if hObject.BackgroundColor == obj.blue
                % set flag 'Solo' true
                obj.audio.speaker(hObject.UserData.Channel).UserData.Solo = true;
                obj.update_playing_speakers();
                % every audio has to be stopped if flag 'Solo' is not true
                for ii=1:length(obj.audio.speaker)
                    if ~obj.audio.speaker(ii).UserData.On
                        obj.audio.speaker(ii).pause;
                    end
                end
                % if reference isplaying but the required audio is not,
                % start required audio (otherwise it is already playing)
                if obj.audio.speaker(ii).UserData.On...
                        && ~obj.audio.speaker(hObject.UserData.Channel).isplaying...
                        && obj.audio.reference.isplaying
                    play(obj.audio.speaker(hObject.UserData.Channel),[obj.audio.reference.CurrentSample ...
                        obj.audio.speaker(hObject.UserData.Channel).TotalSamples]);
                end
                set(hObject,'BackgroundColor', obj.red);
                set(hObject,'HighlightColor', obj.red);
                set(hObject,'ShadowColor', obj.red);
            elseif hObject.BackgroundColor == obj.red
                % set flag 'Solo' false
                obj.audio.speaker(hObject.UserData.Channel).UserData.Solo = false;
                obj.update_playing_speakers();
                % if reference isplaying start every audio which are 'On'
                % are not playing (otherwise it is already playing)
                if obj.audio.reference.isplaying
                    for ii=1:length(obj.audio.speaker)
                        if obj.audio.speaker(ii).UserData.On && ~obj.audio.speaker(ii).isplaying
                            play(obj.audio.speaker(ii),[obj.audio.reference.CurrentSample ...
                                obj.audio.speaker(ii).TotalSamples]);
                        end
                    end
                end
                set(hObject,'BackgroundColor', obj.blue);
                set(hObject,'HighlightColor', obj.blue);
                set(hObject,'ShadowColor', obj.blue);
            end
        end
             
        %% callback_time_slider
        % executes if time slide position is changed (continously)
        function callback_time_slider(obj, hObject, eventData)
            diff1 = obj.handles.timer_cursor.XData(1) - obj.handles.time_cursor_axes.XLim(1);
            diff2 = obj.handles.time_cursor_axes.XLim(2) - obj.handles.timer_cursor.XData(1);
            obj.handles.timer_cursor.XData = [obj.handles.time_slider.Value obj.handles.time_slider.Value];
            if obj.handles.timer_cursor.XData(1)-diff1 < 1
                obj.handles.time_cursor_axes.XLim = [1 obj.var.q_reference/obj.var.qp*obj.show_seconds];
            elseif obj.handles.timer_cursor.XData(1)+diff2 > obj.handles.time_slider.Max;
                obj.handles.time_cursor_axes.XLim =  [obj.handles.time_slider.Max-obj.var.q_reference/obj.var.qp*obj.show_seconds obj.handles.time_slider.Max];
            else
                obj.handles.time_cursor_axes.XLim = [obj.handles.timer_cursor.XData(1)-diff1 obj.handles.timer_cursor.XData(1)+diff2];
            end
            for ii=1:length(obj.audio.speaker)
                obj.handles.soundwave_axes(ii).XLim = obj.handles.time_cursor_axes.XLim;
            end
            CurrentTime = datevec(round(obj.handles.timer_cursor.XData(1) *obj.var.qp + obj.var.delay_in_sample)/obj.audio.reference.SampleRate/86400);
            obj.handles.current_time_str.String = sprintf('%02.0f:%02.0f:%02.0f:%03.0f', CurrentTime(4), CurrentTime(5), fix(CurrentTime(6)), fix((CurrentTime(6)-fix(CurrentTime(6)))*1000) );        
        end
        
        %% release_time_slider
        function release_time_slider(obj, hObject, eventData)
            obj.set_reference_new_with_timecursor();
        end
        
        %% set_reference_new_with_timecursor
        % checks whether the timecursor is within the current buffered
        % audio. if not the audio will be buffered again. One minute beyond
        % the cursor and 4 minutes behind.
        function set_reference_new_with_timecursor(obj)
            obj.var.start_sample = round(obj.handles.timer_cursor.XData(1)*obj.var.qp)-obj.var.offset;
            if obj.var.start_sample >= obj.audio.reference.TotalSamples || obj.var.start_sample < 0
                block_msg_cleanup = obj.set_info_text_at_loading();
                start_sound = round(obj.handles.timer_cursor.XData(1)*obj.var.qp) - (obj.load_seconds - obj.shift_seconds)*obj.var.fs;
                
                endsound = start_sound + obj.load_seconds * obj.var.fs;
                if endsound > obj.var.audio_info.TotalSamples
                    diff = endsound - obj.var.audio_info.TotalSamples;
                    start_sound = start_sound - diff;
                end
                if start_sound < 1
                    start_sound = 1;
                end
                
                obj.remove_vads_of_old_roi();
                obj.init_audioread(start_sound);
                obj.extend_soundwave_plot;
                obj.plot_vads_of_roi();
                if obj.var.vad_tagged
                    obj.is_tagged_vad_in_range();
                end
                obj.var.offset = obj.audio.speaker(1).UserData.SampleRange(1)-1;
                obj.var.start_sample = round(obj.handles.timer_cursor.XData(1)*obj.var.qp)-obj.var.offset;
                clear block_msg_cleanup;
            end
        end
        
        % executes when audiofile is running
        function timefcn(obj, hObject, eventData)
            obj.update_soundwave_plot();
            if mod(obj.var.test,6) == 0 && obj.handles.video_checkbox.Value
                obj.update_video_frame();
            end

            obj.var.start_sample = obj.audio.reference.CurrentSample;
            obj.var.new_sample = obj.audio.reference.CurrentSample;
            obj.var.test = obj.var.test + 1;
            obj.update_time_string();
            obj.update_time_slider();
        end
        
        %% executes when audiofile stops
        function stopfcn(obj, hObject, eventData)
            obj.set_panel_button(obj.handles.play_button, eventData, 'Play', obj.blue);
            obj.update_soundwave_plot();
            obj.update_time_string();
            obj.update_time_slider();
            obj.var.start_sample = obj.audio.reference.CurrentSample;
            obj.var.new_sample = obj.audio.reference.CurrentSample;
            
            % executes if audio is running out of buffered time
            if obj.var.is_playing ...
                    && obj.audio.reference.CurrentSample == 1
                if ~obj.var.vad_is_playing
                    start_sound = (obj.audio.speaker(1).UserData.SampleRange(2)+1) - (obj.load_seconds - obj.shift_seconds)*obj.var.fs;
                    
                    % if audio is actual running out of end of file
                    if start_sound > obj.var.audio_info.TotalSamples
                        obj.var.start_sample = 1;
                        obj.var.is_playing = false;
                        return;
                    end
                    
                    block_msg_cleanup = obj.set_info_text_at_loading();
                    obj.remove_vads_of_old_roi();
                    obj.init_audioread(start_sound);
                    obj.extend_soundwave_plot;
                    obj.plot_vads_of_roi();
                    obj.var.offset = obj.audio.speaker(1).UserData.SampleRange(1)-1;
                    obj.var.start_sample = (obj.load_seconds - obj.shift_seconds)*obj.var.fs;
                    
                    clear block_msg_cleanup;
                    obj.play(obj.handles.play_button, eventData);
                end
            end
            
            % if just vad segment playing stops
            if obj.var.vad_is_playing
                if obj.var.vad_tagged
                    obj.var.is_playing = false;
                    obj.var.start_sample = round(obj.var.last_sample_plot*obj.var.qp)-obj.var.offset;
                    set(obj.handles.timer_cursor,'XData', [obj.var.last_sample_plot obj.var.last_sample_plot]);
                    obj.var.vad_is_playing = false;
                end
            end
        end
 
        %% callback_windowkey_release
        % Definitions of HotKeys. Executes at releasing the key
        function callback_windowkey_release(obj, hObject, eventData)
            if strcmp(eventData.Character,'') && (strcmp(eventData.Key,'shift')...
                    || strcmp(eventData.Key,'control') || strcmp(eventData.Key,'alt'))
                return;
            end

            switch eventData.Key
                case {'space','f7','f9'}
                    obj.callback_play(obj.handles.play_button, eventData);
                    return;
                case 'f1'
                    obj.callback_clicked_toggle(obj.handles.edit_tool, eventData);
                    return;
                case 'f2'
                    obj.callback_clicked_toggle(obj.handles.search_tool, eventData);
                    return;
                case 'f3'
                    obj.callback_clicked_toggle(obj.handles.zoom_in_tool, eventData);
                    return;
                case 'f4'
                    obj.callback_clicked_toggle(obj.handles.zoom_out_tool, eventData);
                    return;
                case 'delete'
                    obj.delete_vad_or_lvltwo();
                    return;
                case 'x'
                    if strcmp(eventData.Modifier, 'control')
                        obj.delete_vad_or_lvltwo();
                        return;
                    end
                case 'f12'
                    if ~obj.var.is_playing
                        if ~obj.var.vad_is_playing
                            obj.var.last_sample_plot = obj.handles.timer_cursor.XData(1);
                        end
                        obj.play_vad_segment(obj.handles.play_button, eventData);
                    end
                    return;
                case {'f8','f11','f5','f10'}
                    obj.release_time_slider();
                    return;
                case 'rightarrow'
                    if strcmp(eventData.Modifier, 'control')
                        obj.change_vad_size('right', 'Onset');
                    elseif strcmp(eventData.Modifier, 'alt')
                        obj.change_vad_size('right', 'Offset');
                    else
                        obj.goto_next_vad('right');
                    end
                    return;
                case 'leftarrow'
                    if strcmp(eventData.Modifier, 'control')
                        obj.change_vad_size('left', 'Onset');
                    elseif strcmp(eventData.Modifier, 'alt')
                        obj.change_vad_size('left', 'Offset');
                    else
                        obj.goto_next_vad('left');
                    end
                    return;
                case 'uparrow'
                    obj.goto_next_vad('up');
                    return;
                case 'downarrow'
                    obj.goto_next_vad('down');
                    return;
                case 'pagedown'
%                     obj.goto_uncoded_vad('next');
                      obj.goto_first_uncoded_vad();
                case 'pageup'
%                     obj.goto_uncoded_vad('back');
                    
            end
            
            % if any vad is tagged and the user uses a customkeyboard the
            % corresponding code will be added or removed to/from the vad.
            if obj.var.vad_tagged
                if obj.handles.custom_keyboard_checkbox.Value
                    idx = strfind(char(obj.var.lookuptable(:,1))',eventData.Character);
                    code = char(obj.var.lookuptable(idx,2));
                    if isempty(code)
                       return; 
                    end
                    old_code = char(obj.handles.annotation_jtext_pane.getText);
                    
                    old_code_splitted = strsplit(old_code,';');
                    old_code_splitted = strtrim(old_code_splitted);
                    
                    log = zeros(1,length(old_code_splitted));
                    for ii=1:size(code,1)
                        log_tmp = strncmpi(old_code_splitted,strtrim(code(ii,:)),length(code));
                        log = log | log_tmp;
                    end
                    
                    
                    
                    if ~sum(log)
                        if ~isempty(old_code)
                            for ii=1:size(code,1)
                                old_code =  [old_code,'; ',strtrim(code(ii,:))];
                            end
                            code = old_code;
                        else
                            code = strjoin(cellstr(code),'; ');
                        end
                        
                    else
                        old_code_splitted = old_code_splitted(~log);
                        if ~isempty(old_code_splitted)
                            code = char(old_code_splitted(1));
                            for jj=2:length(old_code_splitted)
                                if iscellstr(old_code_splitted(jj))
                                    code = [code,'; ',char(old_code_splitted(jj))];
                                end
                            end
                        else
                            code = '';
                        end
                    end
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Code = code;
                    obj.handles.annotation_jtext_pane.setText(code);
                    obj.update_text_plot();
                    invalid_code = obj.is_code_invalid();
            
                    if invalid_code
                        obj.handles.annotation_jtext_pane.setBackground(java.awt.Color(0.8627, 0.1961, 0.1843));
                    else
                        obj.handles.annotation_jtext_pane.setBackground(java.awt.Color(1, 1, 1));
                    end
                end
            end
        end
        
        %% callback_windowkey_press
        % Definitions of HotKeys. Executes at pressing the key
        function callback_windowkey_press(obj, hObject, eventData)
            if strcmp(eventData.Character,'') && (strcmp(eventData.Key,'shift')...
                    || strcmp(eventData.Key,'control') || strcmp(eventData.Key,'alt'))
                return;
            end
            
            % definitions of the fast forward and so on keys on the
            % CustomKeyboard
            switch eventData.Key
                case 'f11'
                    obj.change_time_slider_customkeyboard('forward', 'small');
                    return;
                case 'f5'
                    obj.change_time_slider_customkeyboard('backward', 'big');
                    return;
                case 'f8'
                    obj.change_time_slider_customkeyboard('forward', 'big');
                    return;
                case 'f10'
                    obj.change_time_slider_customkeyboard('backward', 'small');
                    return;
            end
            
        end
        
        %% goto_first_uncoded_vad
        % Go to the first uncoded vad
        function goto_first_uncoded_vad(obj)
            if obj.var.vad_tagged
                if isempty(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject.String)
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.yellow;
                else
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.green;
                end
            end
            
            start_points = [];
            vad = [];
            for ii=1:length(obj.audio.speaker)
                if ~isempty(obj.audio.data(ii).vad)
                    start_points = [start_points, obj.audio.data(ii).vad.PlotData];
                    vad = [vad, obj.audio.data(ii).vad];
                end
            end
            start_points = start_points(1,:);
            
            [~, i] = sort(start_points);  
             vad = vad(i);
            
            for ii=1:length(vad)
                if isempty(char(vad(ii).Code))
                    obj.var.vad_tagged = vad(ii).Object.UserData.ID;
                    obj.update_view_boundaries();
                    obj.check_current_audio_buffer();
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.red;
                    obj.show_info();
                    return;
                end
            end
            obj.var.vad_tagged = [0 0];
            warndlg('There is no uncoded VAD!');
        end
        
        %% goto_uncoded_vad
        % Go to the first uncoded vad depending on the search direction
        function goto_uncoded_vad(obj, direction)
            if obj.var.vad_tagged
                if isempty(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject.String)
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.yellow;
                else
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.green;
                end
            end
            
            start_points = [];
            vad = [];
            for ii=1:length(obj.audio.speaker)
                if ~isempty(obj.audio.data(ii).vad)
                    start_points = [start_points, obj.audio.data(ii).vad.PlotData];
                    vad = [vad, obj.audio.data(ii).vad];
                end
            end
            
            start_points = start_points(1,:);
            % the edge where the searching will be begin
            edge = obj.handles.time_cursor_axes.XLim(1);
            
            if strcmp(direction, 'next')
                [start_points, i] = sort(start_points);
                
                vad = vad(i);
                idx = find(start_points > edge);
            else % if strcmp(direction, 'back')
                [start_points, i] = sort(start_points,'descend');
                vad = vad(i);
                idx = find(start_points < edge);
            end
            
            if ~isempty(idx)
                for ii=idx(1):idx(end)
                    if isempty(char(vad(ii).Code))
                        obj.var.vad_tagged = vad(ii).Object.UserData.ID;
                        obj.update_view_boundaries();
                        obj.check_current_audio_buffer();
                        obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.red;
                        obj.show_info();
                        return;
                    end
                end
            end
            obj.var.vad_tagged = [0 0];
            warndlg('There is no uncoded VAD!');
            
        end
        
        %% change_time_slider_customkeyboard
        function change_time_slider_customkeyboard(obj, direction, stepsize)
            if strcmp(stepsize, 'big')
                kk=2;
            else
                kk=1;
            end
            if strcmp(direction, 'forward')
                step = obj.handles.time_slider.SliderStep(kk)*obj.handles.time_slider.Max;
            else
                step = -obj.handles.time_slider.SliderStep(kk)*obj.handles.time_slider.Max;
            end
            if obj.handles.time_slider.Value + step < 1
                obj.handles.time_slider.Value = obj.handles.time_slider.Min;
            elseif obj.handles.time_slider.Value + step > obj.handles.time_slider.Max
                obj.handles.time_slider.Value = obj.handles.time_slider.Max;
            else
                obj.handles.time_slider.Value = obj.handles.time_slider.Value + step;
            end
            obj.callback_time_slider();
        end
        
        %% callback close figure
        % executes when the main figure will be closed.
        function callback_close_figure(obj, hObject, eventData)
            delete(obj.handles.fig);            
        end
        
        %% delete_vad_or_lvltwo
        function delete_vad_or_lvltwo(obj)
            if obj.var.vad_tagged
                obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Deleted = true;
                delete(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object);
                delete(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject);
                obj.sort_vads(obj.var.vad_tagged(1));
                obj.var.vad_tagged = [0 0];
            elseif obj.var.lvl2_nr
                choice = questdlg('Do you want to delete this Set','Removing Set','Yes','No','No');
                
                switch choice
                    case 'Yes'
                        obj.audio.lvl_two(obj.var.lvl2_nr).Deleted = true;
                        delete(obj.audio.lvl_two(obj.var.lvl2_nr).OnsetLineObject);
                        delete(obj.audio.lvl_two(obj.var.lvl2_nr).OffsetLineObject);
                        obj.var.lvl2_nr = 0;
                        obj.audio.lvl_two = obj.audio.lvl_two(~[obj.audio.lvl_two.Deleted]);
                    case 'No'
                        return;
                end
            end
            obj.show_info();
        end
        
        %% change_vad_size
        function change_vad_size(obj, direction, bound)
            if obj.var.vad_tagged
                xdata = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData;
                if strcmp(direction, 'right')
                    diff = obj.show_seconds * obj.var.fs * 0.00002;
                else
                    diff = -obj.show_seconds * obj.var.fs * 0.00002;
                end
                if strcmp(bound, 'Onset')
                    xdata(1) = xdata(1)+diff; xdata(4) = xdata(4)+diff;
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData = xdata;
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Onset = obj.sample_in_plot_to_time(xdata(1));
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject.Position(1) = xdata(1);
                else
                    xdata(2:3) = xdata(2:3)+diff;
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.XData = xdata;
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Offset = obj.sample_in_plot_to_time(xdata(2));
                end
            end
        end
        
        %% goto_next_vad
        % tag the next vad, executed by arrow buttons
        function goto_next_vad(obj, direction)
            if obj.var.vad_tagged
                if isempty(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject.String)
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.yellow;
                else
                    obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.green;
                end
                
                vad_left_bound = obj.time_to_sample_in_plot(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Onset);
                vad_right_bound = obj.time_to_sample_in_plot(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Offset);
                % if current tagged is not in current view
                if vad_left_bound < obj.handles.time_cursor_axes.XLim(1) || vad_right_bound > obj.handles.time_cursor_axes.XLim(2)
                    obj.var.vad_tagged(1) = 1;
                    speaker_nr = obj.first_trace_with_vad_in_view('down');
                    vad_nr = obj.find_first_vad_in_view(speaker_nr);
                    obj.var.vad_tagged = [speaker_nr vad_nr];
                else
                    if strcmp(direction, 'right') && size(obj.audio.data(obj.var.vad_tagged(1)).vad,2) > obj.var.vad_tagged(2)
                        obj.var.vad_tagged = [obj.var.vad_tagged(1) obj.var.vad_tagged(2)+1];
                    elseif strcmp(direction, 'left') && obj.var.vad_tagged(2) > 1
                        obj.var.vad_tagged = [obj.var.vad_tagged(1) obj.var.vad_tagged(2)-1];
                    elseif strcmp(direction, 'up')
                        if obj.var.vad_tagged(1) == 1
                            speaker_nr = obj.var.vad_tagged(1);
                        else
                            speaker_nr = obj.first_trace_with_vad_in_view(direction);
                        end
                        vad_nr = obj.find_first_vad_in_view(speaker_nr);
                        obj.var.vad_tagged = [speaker_nr vad_nr];
                    elseif strcmp(direction, 'down')
                        if obj.var.vad_tagged(1) == length(obj.audio.speaker)
                            speaker_nr = obj.var.vad_tagged(1);
                        else
                            speaker_nr = obj.first_trace_with_vad_in_view(direction);
                        end
                        vad_nr = obj.find_first_vad_in_view(speaker_nr);
                        obj.var.vad_tagged = [speaker_nr vad_nr];
                    end
                end
            else
                obj.var.vad_tagged(1) = 1;
                speaker_nr = obj.first_trace_with_vad_in_view('down');
                vad_nr = obj.find_first_vad_in_view(speaker_nr);
                obj.var.vad_tagged = [speaker_nr vad_nr];
            end
            obj.update_view_boundaries();
            obj.update_buffered_audio();
            obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.red;
            obj.show_info();
        end
        
        %% update_buffered_audio
        % update the buffered audio and plots and so if necessary
        function update_buffered_audio(obj)
            range = [obj.handles.soundwave(1).XData(1) obj.handles.soundwave(1).XData(end)];
            vad_left_bound = obj.time_to_sample_in_plot(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Onset);
            vad_right_bound = obj.time_to_sample_in_plot(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Offset);
            
            if vad_left_bound < range(1) || vad_right_bound > range(2)
                obj.handles.timer_cursor.XData = vad_left_bound;
                obj.set_reference_new_with_timecursor();
            end
        end
        
        %% update_view_boundaries
        function update_view_boundaries(obj)
            vad_left_bound = obj.time_to_sample_in_plot(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Onset);
            vad_right_bound = obj.time_to_sample_in_plot(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Offset);
            if vad_left_bound < obj.handles.time_cursor_axes.XLim(1) || vad_right_bound > obj.handles.time_cursor_axes.XLim(2)
                left_bound = vad_left_bound - obj.var.q_reference/obj.var.qp*obj.show_seconds/2;
                right_bound = vad_left_bound + obj.var.q_reference/obj.var.qp*obj.show_seconds/2;
                obj.handles.time_cursor_axes.XLim = [left_bound right_bound];
                for ii=1:length(obj.audio.speaker)
                    obj.handles.soundwave_axes(ii).XLim = obj.handles.time_cursor_axes.XLim;
                end
            end
        end
        
        %% find_first_vad_in_view
        function vad_nr = find_first_vad_in_view(obj, speaker_nr)
            vad_nr = [];
            left_bound = obj.handles.soundwave_axes(speaker_nr).XLim(1);
            for ii=1:length(obj.audio.data(speaker_nr).vad)
                vad_bound = obj.time_to_sample_in_plot(obj.audio.data(speaker_nr).vad(ii).Onset);
                if vad_bound > left_bound
                   vad_nr = ii;
                   return;
                end
            end
        end
              
        %% init_audioread
        function init_audioread(obj, start_sample)
            
            seconds = obj.load_seconds;
            if ~isempty(obj.audio)
                for ii=1:length(obj.audio.speaker)
                    userdata(ii) = obj.audio.speaker(ii).UserData;
                    delete(obj.audio.speaker(ii));
                end
            end
            for ii=1:length(obj.var.audio_src)
                obj.update_msg_block(['Loading Audio Track ',num2str(ii)]);
                audio_info = audioinfo([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, obj.var.audio_src(ii).name]);
                obj.var.fs = audio_info.SampleRate;
                if (obj.var.fs*seconds+start_sample) > audio_info.TotalSamples
                    end_sample = audio_info.TotalSamples;
                else
                    end_sample = obj.var.fs*seconds+start_sample;
                end
                
                [obj.audio.data(ii).samples_plot, obj.var.fs] = audioread([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, obj.var.audio_src(ii).name],[start_sample end_sample]);
                
                obj.audio.speaker(ii) = audioplayer(obj.audio.data(ii).samples_plot,obj.var.fs);
                if exist('userdata','var')
                    obj.audio.speaker(ii).UserData = userdata(ii);
                end
                obj.audio.speaker(ii).UserData.SampleRange = [start_sample end_sample];
            end
        end
        
        %% init_soundwave_plot
        function init_soundwave_plot(obj)
            
            % determine downsample factor depending on window size and
            % quality of plot
            obj.var.p = round(obj.handles.fig.Position(3)* obj.width_of_axes/10)*5;
            obj.var.q_reference = obj.audio.reference.SampleRate;
            obj.var.qp = round(fix(obj.var.q_reference/obj.var.p)*obj.quality_of_plot);
            
            for ii=1:length(obj.audio.speaker)
                obj.update_msg_block(['Plotting Audio Track ',num2str(ii)]);
                
                % create soundwave axes ii
                obj.handles.soundwave_axes(ii) = axes(...
                    'Parent', obj.handles.main_panel,...
                    'Units', 'normalized',...
                    'Position', [0.23, (0.865 - obj.space_between_axes*(ii-1)),...
                    obj.width_of_axes, .1],...
                    'Visible', 'on');   
                
                % downsample it
                obj.audio.data(ii).samples_plot = obj.audio.data(ii).samples_plot(1:obj.var.qp:end);
                % convert to single values (sufficient for plotting)
                obj.audio.data(ii).samples_plot = single(obj.audio.data(ii).samples_plot);

                y_range(ii) = max(abs(obj.audio.data(ii).samples_plot)) * 3/4;
                obj.var.t = 1:1:length(obj.audio.data(ii).samples_plot);
                obj.handles.soundwave(ii) = plot(obj.handles.soundwave_axes(ii),obj.var.t,obj.audio.data(ii).samples_plot,'Color','b');
                obj.handles.soundwave_axes(ii).UserData.ID = ii;
                obj.handles.soundwave_axes(ii).XTick = [];
                obj.handles.soundwave_axes(ii).YTick = [];
                obj.handles.soundwave_axes(ii).NextPlot = 'add';
                obj.handles.soundwave_axes(ii).YColor_I = obj.handles.main_panel.BackgroundColor;
                obj.handles.soundwave_axes(ii).XLim = [1 obj.var.q_reference/obj.var.qp*obj.show_seconds];
                
                set(obj.handles.soundwave_axes(ii), 'ButtonDownFcn', @obj.callback_axes);
                set(obj.handles.soundwave(ii), 'ButtonDownFcn', @obj.callback_axes);
                
                [~, b] = regexp(obj.var.audio_src(ii).name,'_Tr\d+');
                
                if isempty(b)
                    b = num2str(ii);
                else
                    b = obj.var.audio_src(ii).name(b);
                end
                
                % create Speaker Label
                obj.handles.data(ii).speaker_name = text(0.22, (0.915 - obj.space_between_axes*(ii-1)), b,'Parent',obj.handles.main_axes,'FontSize', 12);
                drawnow;
                set(obj.handles.data(ii).speaker_name, 'ButtonDownFcn', @obj.callback_editing_label);
            end
            y_range = max(y_range);
            for ii=1:length(obj.audio.speaker)
               obj.handles.soundwave_axes(ii).YLim = [-y_range y_range]; 
            end
            
            axes_height1 = obj.handles.soundwave_axes(length(obj.audio.speaker)).Position(2);
            axes_height2 = obj.handles.soundwave_axes(1).Position(2)...
                + obj.handles.soundwave_axes(1).Position(4) - axes_height1;
            
            % create axes for time cursor behind the soundwave axes
            obj.handles.time_cursor_axes = axes(...
               'Parent', obj.handles.main_panel,...
               'Units', 'normalized',...
               'Position', [0.23, axes_height1, obj.width_of_axes, axes_height2],...
               'YLim', [-1 1],...
               'Visible', 'off');
           
           set(obj.handles.main_panel, 'ButtonDownFcn', @obj.callback_time_axes_beyond);
           
           obj.handles.time_cursor_axes.XLim = obj.handles.soundwave_axes(1).XLim;
           obj.handles.timer_cursor = line([1 1],[-1 1],'Parent',obj.handles.time_cursor_axes,'Color','g');
           
           % create group name Label:
           obj.handles.group_name_place = text(0.265, 0.99, 'GroupName: ','Parent',obj.handles.main_axes,'FontSize', 10,'HorizontalAlignment','right');
           obj.handles.group_name = text(0.265, 0.99, 'Click on me!','Parent',obj.handles.main_axes,'FontSize', 10, 'Interpreter', 'none');
           set(obj.handles.group_name, 'ButtonDownFcn', @obj.callback_editing_label);
        end
        
        %% init_reference_plot
        function init_reference_plot(obj)
            % determine wether there already exists a SAD.mat file within
            % the profect folder
            obj.var.sad_src = dir(fullfile(obj.var.dbdir,filesep,obj.name_of_tmp_folder,filesep, '*.mat'));
            
            obj.var.SAD_exist = false;
            for ii = 1:length(obj.var.sad_src)
                if strfind(obj.var.sad_src(ii).name, 'SAD')
                    obj.var.SAD_exist = true;
                    break;
                end
            end
            
            if ~obj.var.SAD_exist
                set(obj.handles.vad_button,'BackgroundColor', obj.blue);
                set(obj.handles.vad_button,'ShadowColor', obj.blue);
                set(obj.handles.vad_button,'HighlightColor', obj.blue);
            end
               
            if ~isempty(obj.var.excel_src)
                obj.update_msg_block('Plotting already marked areas from Excel file');
                
                % if there are several excel files, ask the user which one
                % shall be used.
                if size(obj.var.excel_src,1) > 1

                    file_list = {obj.var.excel_src.name}';
                    [s,v] = listdlg('PromptString','Select a excel file:',...
                        'SelectionMode','single',...
                        'ListString',file_list);
                    
                    if v
                        obj.var.excel_src = obj.var.excel_src(s);
                    else
                        obj.var.excel_src = obj.var.excel_src(1);
                    end
                else
                    obj.var.excel_src = obj.var.excel_src(1);
                end
                
                [~,~,excel_table] = xlsread([obj.var.dbdir, filesep, char(obj.var.excel_src.name)]);
                
                header = excel_table(1,:);
                
                % determine the number of speakers
                idx_speaker = strncmp(header, 'Sprecher',8);
                log_lvl3 = find(cell2mat(excel_table(2:end,1)) == 3 | ...
                    strcmp(excel_table(2:end,1),'E')) + 1;
                
                if ~isempty(log_lvl3)            
                    speaker_cell = excel_table(log_lvl3,idx_speaker);
                    speaker_cell_restore = excel_table(2:end,idx_speaker);
                    for ii=1:length(speaker_cell)
                        if isnumeric(speaker_cell{ii})
                            speaker_cell{ii} = num2str(speaker_cell{ii});
                        end
                    end
                    for ii=1:length(speaker_cell_restore)
                        if isnumeric(speaker_cell_restore{ii})
                            speaker_cell_restore{ii} = num2str(speaker_cell_restore{ii});
                        end
                    end
                    got_everybody = false;
                    speaker = [];
                    while ~got_everybody
                        next_active_speaker = speaker_cell(1);
                        speaker = [speaker; next_active_speaker];
                        idx = strncmp(speaker_cell, char(next_active_speaker),1);
                        speaker_cell = speaker_cell(~idx);
                        if isempty(speaker_cell)
                            got_everybody = true;
                        end
                    end
                    speaker = sort(speaker);
                    
                    % change speaker label depending on the speaker name
                    for ii=1:length(speaker)
                        obj.audio.data(ii).vad = [];
                        obj.handles.data(ii).speaker_name.String = char(speaker(ii));
                    end
                end                
                obj.audio.lvl_two = [];
                
                idx_level = strncmp(header, 'Level',5) | strncmp(header, 'Type',4);
                idx_onset = strncmp(header, 'Onset',5) | strncmp(header, 'Entry',5);
                idx_offset = strncmp(header, 'Offset',6) | strncmp(header, 'Exit',6);
                idx_memo = strncmp(header, 'Memo',6);
                idx_classes = ~(idx_speaker + idx_level + idx_offset + idx_onset + idx_memo);
                
                % determine range of viewing where existing vads has to be plotted
                range = [obj.handles.soundwave(1).XData(1) obj.handles.soundwave(1).XData(end)];
                
                for ii=2:size(excel_table,1)
                    if cell2mat(excel_table(ii,idx_level)) == 3 || strcmp(excel_table(ii,idx_level),'E')

                        active_speaker = speaker_cell_restore(ii-1);
                        speaker_nr = strncmp(speaker, char(active_speaker),1);
                        vad_nr = length(obj.audio.data(speaker_nr).vad) + 1;
                        Onset = cell2mat(excel_table(ii,idx_onset));
                        if ischar(Onset)
                           Onset =  obj.convert_oldversion_time_to_new(Onset);
                        end
                        Offset = cell2mat(excel_table(ii,idx_offset));
                        if ischar(Offset)
                           Offset =  obj.convert_oldversion_time_to_new(Offset);
                        end
                        obj.audio.data(speaker_nr).vad(vad_nr).Onset = Onset;
                        obj.audio.data(speaker_nr).vad(vad_nr).Offset = Offset;
                        codes = excel_table(ii,idx_classes);
                        code = [];
                        for jj=1:length(codes)
                            if iscellstr(codes(jj))
                                code = [char(codes(jj)),'; ',code];
                            elseif ~isnan(cell2mat(codes(jj)))
                                code = [num2str(cell2mat(codes(jj))),'; ',code];
                            end
                        end
                        obj.audio.data(speaker_nr).vad(vad_nr).Code = code(1:end-2);
                        
                        if isempty(obj.audio.data(speaker_nr).vad(vad_nr).Code)
                            color = obj.yellow;
                        else
                            color = obj.green;
                        end
                        
                        if iscellstr(excel_table(ii,idx_memo))
                            obj.audio.data(speaker_nr).vad(vad_nr).Memo = char(excel_table(ii,idx_memo));
                        else
                            obj.audio.data(speaker_nr).vad(vad_nr).Memo = '';
                        end
                        
                        start_pt = obj.time_to_sample_in_plot(obj.audio.data(speaker_nr).vad(vad_nr).Onset);
                        end_pt = obj.time_to_sample_in_plot(obj.audio.data(speaker_nr).vad(vad_nr).Offset);
                        xdata = [start_pt; end_pt; end_pt; start_pt];
                        y = obj.handles.soundwave_axes(speaker_nr).YLim(2);
                        ydata = [y; y; -y; -y];
                        zdata = zeros(4,1);
                        
                        obj.audio.data(speaker_nr).vad(vad_nr).PlotData = xdata;
                        
                        if start_pt > range(1) && start_pt < range(2)
                            show_vad = true;
                        else
                            show_vad = false;
                        end
                        
                        if show_vad
                            % if a vad has a memo concatenate a '*' to the
                            % string above the vad segments within the
                            % soundwave plot
                            code = obj.audio.data(speaker_nr).vad(vad_nr).Code;
                            if ~isempty(obj.audio.data(speaker_nr).vad(vad_nr).Memo)
                                code = strcat(char(code),'*');
                            else
                                code = char(code);
                            end
                            
                            obj.audio.data(speaker_nr).vad(vad_nr).Object = patch(xdata,ydata,zdata,'parent',obj.handles.soundwave_axes(speaker_nr),'FaceColor', color, 'FaceAlpha' , 0.3);
                            obj.audio.data(speaker_nr).vad(vad_nr).TextObject = text(start_pt,double(y*1.1),code,'Parent',obj.handles.soundwave_axes(speaker_nr),'FontSize',8,'Interpreter','none');
                        else
                            obj.audio.data(speaker_nr).vad(vad_nr).Object = [];
                            obj.audio.data(speaker_nr).vad(vad_nr).TextObject = [];
                        end
                        set(obj.audio.data(speaker_nr).vad(vad_nr).Object, 'ButtonDownFcn', @obj.callback_axes);
                        obj.audio.data(speaker_nr).vad(vad_nr).Object.UserData.ID = [find(speaker_nr == true) vad_nr];
                        
                        obj.audio.data(speaker_nr).vad(vad_nr).Deleted = false;
                        
                    % Level 2 Settings    
                    elseif cell2mat(excel_table(ii,idx_level)) == 2 || strcmp(excel_table(ii,idx_level),'T')
                        nr = length(obj.audio.lvl_two) + 1;
                        
                        Onset = cell2mat(excel_table(ii,idx_onset));
                        if ischar(Onset)
                           Onset =  obj.convert_oldversion_time_to_new(Onset);
                        end
                        Offset = cell2mat(excel_table(ii,idx_offset));
                        if ischar(Offset)
                           Offset =  obj.convert_oldversion_time_to_new(Offset);
                        end
                        obj.audio.lvl_two(nr).Onset = Onset;
                        obj.audio.lvl_two(nr).Offset = Offset;
                        onset_plot = obj.time_to_sample_in_plot(Onset);
                        offset_plot = obj.time_to_sample_in_plot(Offset);
                        obj.audio.lvl_two(nr).OnsetLineObject = line([onset_plot onset_plot],[-.97 .97],'Parent',obj.handles.time_cursor_axes,'Color',[obj.red .5],'Linewidth',2,'Marker','>');
                        obj.audio.lvl_two(nr).OnsetLineObject.UserData = struct('Nr',nr,'Type','Onset');
                        obj.audio.lvl_two(nr).OffsetLineObject = line([offset_plot offset_plot],[-.97 .97],'Parent',obj.handles.time_cursor_axes,'Color',[obj.red .5],'Linewidth',2,'Marker','<');
                        obj.audio.lvl_two(nr).OffsetLineObject.UserData = struct('Nr',nr,'Type','Offset');
                        obj.audio.lvl_two(nr).Deleted = false;
                        set(obj.audio.lvl_two(nr).OffsetLineObject, 'ButtonDownFcn', @obj.callback_time_axes_beyond);
                        set(obj.audio.lvl_two(nr).OnsetLineObject, 'ButtonDownFcn', @obj.callback_time_axes_beyond);
                        
                        if iscellstr(excel_table(ii,idx_memo))
                            obj.audio.lvl_two(nr).Memo = char(excel_table(ii,idx_memo));
                        else
                            obj.audio.lvl_two(nr).Memo = '';
                        end
                    % determine group name    
                    elseif cell2mat(excel_table(ii,idx_level)) == 1 || strcmp(excel_table(ii,idx_level),'S')
                        if iscellstr(excel_table(ii,idx_memo))
                            obj.handles.group_name.String = char(excel_table(ii,idx_memo));
                        end
                    end
                    
                end

            else
                % if there is no excel-file and no SAD.mat file
                if ~obj.var.SAD_exist
                    choice = questdlg('There is no Excel-File and automatic SAD yet! Do you want to start the automatic SAD recognition? This may take some time!','Automatic SAD recognition','Yes','No','Yes');
                    
                    switch choice
                        case 'Yes'
                            obj.update_msg_block('Start Preprocessing.');
                            obj.create_dialog_window();
                            drawnow;
                            
                            obj.start_sad_processing();
                            delete(obj.handles.dialog);
                            if ~obj.var.sad_canceled
%                                 block_msg_cleanup = obj.set_info_text_at_loading();
                                obj.plot_automatic_vads();
                            end
                            
%                             clear block_msg_cleanup;
                        case 'No'
                            msgbox('The automatic SAD recognition can always be started by pressing the ''SAD'' button','Message','CreateMode','modal');
                            set(obj.handles.vad_button,'BackgroundColor', obj.blue);
                            set(obj.handles.vad_button,'ShadowColor', obj.blue);
                            set(obj.handles.vad_button,'HighlightColor', obj.blue);
                    end
                % if there is no excel-file but a SAD.mat file    
                else
                    obj.plot_automatic_vads();
                end
            end
        end
        
        %% plot_automatic_vads
        % plots the vads determined by the VAD algorithm
        function plot_automatic_vads(obj)
            
            load([obj.var.dbdir,filesep,'.tmp\SAD.mat'],'SAD');
            
            
            audio_info = audioinfo([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, obj.var.audio_src(1).name]);
            obj.update_msg_block('Plotting VADs');
            n_len = floor(audio_info.TotalSamples * 1/obj.var.qp);
            xsad = obj.var.frame_len/(2*obj.var.qp):obj.var.frame_shift/(obj.var.qp):n_len-obj.var.frame_len/(2*obj.var.qp);

            % determine start and end point of vads
            for jj=1:length(obj.audio.speaker)
                flag = false;
                start_points = [];
                end_points = [];
                for ii=1:length(SAD)
                    if SAD(ii,jj) ~=flag;
                        if ~flag
                            start_points = [start_points xsad(ii)];
                        else
                            end_points = [end_points xsad(ii-1)];
                        end
                        flag= ~flag;
                        
                    end
                end
                if length(start_points) < length(end_points)
                    end_points = endpoints(1:length(start_points));
                else
                    start_points = start_points(1:length(end_points));
                end
                data(jj).points = [start_points; end_points];
            end            
            
            % Plot VADs which are within the range otherwise just make the
            % struct.
            range = [obj.handles.soundwave(1).XData(1) obj.handles.soundwave(1).XData(end)];
            kk = 0;
            for jj=1:length(obj.audio.speaker)
                y = obj.handles.soundwave_axes(jj).YLim(2);
                ydata = [y; y; -y; -y];
                zdata = zeros(4,1);
                
                log = strncmp(fieldnames(obj.audio.data(jj)),'vad',3);
                if sum(log) > 0
                    vad_offset = length(obj.audio.data(jj).vad);
                else
                    vad_offset = 0;
                end
                
                for ii=1:size(data(jj).points,2)
                    kk = kk + 1;
                    vad_nr = ii + vad_offset;
                    disp(['Speaker ',num2str(jj),'. SAD ',num2str(ii),'/',num2str(length(data(jj).points))]);
                    start_pt = data(jj).points(1,ii);
                    end_pt = data(jj).points(2,ii);
                    obj.audio.data(jj).vad(vad_nr).Onset = obj.sample_in_plot_to_time(start_pt);
                    obj.audio.data(jj).vad(vad_nr).Offset = obj.sample_in_plot_to_time(end_pt);
                    obj.audio.data(jj).vad(vad_nr).Code = '';
                    obj.audio.data(jj).vad(vad_nr).Memo = '';
                    
                    
                    xdata = [start_pt; end_pt; end_pt; start_pt];
                    obj.audio.data(jj).vad(vad_nr).PlotData = xdata;
                    if start_pt > range(1) && start_pt < range(2)
                        show_vad = true;
                    else
                        show_vad = false;
                    end
                    
                    if show_vad
                        obj.audio.data(jj).vad(vad_nr).Object = patch(xdata,ydata,zdata,'parent',...
                            obj.handles.soundwave_axes(jj),'FaceColor', obj.yellow, 'FaceAlpha' , 0.3);
                        obj.audio.data(jj).vad(vad_nr).TextObject = text(start_pt,double(y*1.1),...
                            obj.audio.data(jj).vad(vad_nr).Code,'Parent',obj.handles.soundwave_axes(jj),'Interpreter','none');
                    else
                        obj.audio.data(jj).vad(vad_nr).Object = [];
                        obj.audio.data(jj).vad(vad_nr).TextObject = [];
                    end
                    
                    set(obj.audio.data(jj).vad(vad_nr).Object, 'ButtonDownFcn', @obj.callback_axes);
                    obj.audio.data(jj).vad(vad_nr).Object.UserData.ID = [jj ii];
                    
                    obj.audio.data(jj).vad(vad_nr).Deleted = false;
                    msg_str = 'Plotting VADs! %1.1f%% Done!';
                    obj.update_msg_block(msg_str);
                end
            end
        end
        
        %% start_sad_processing
        % started the vad recognition algorithm in a cluster
        function start_sad_processing(obj)
            % Start automativ VAD recognition at the end of the last
            % manually VAD.
            %%%
            log = strncmp(fieldnames(obj.audio.data),'vad',3);
            if sum(log) > 0
                end_points = [];
                for ii=1:length(obj.audio.speaker)
                    if ~isempty(obj.audio.data(ii).vad)
                        end_points = [end_points, obj.audio.data(ii).vad.PlotData];
                    end
                end
                beginning_sample = ceil(ceil(max(end_points(2,:))*obj.var.qp)/obj.var.frame_len)*obj.var.frame_len;      
            else
                beginning_sample = 1;
            end
            %%%
            
            audio_src = [dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, '*_' num2str(obj.var.goal_fs/1000) 'kHz.wav']));...
                         dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, '*_' num2str(obj.var.goal_fs/1000) 'kHz.wma']));...
                         dir(fullfile([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, '*_' num2str(obj.var.goal_fs/1000) 'kHz.mp3']))];
            
             if ~isempty(audio_src)
                 for ii=1:length(audio_src)
                     files(ii) = cellstr([obj.var.dbdir,filesep,obj.name_of_tmp_folder,filesep,audio_src(ii).name]);
                 end
             else
                 for ii=1:length(obj.var.audio_src)
                     files(ii) = cellstr([obj.var.dbdir,filesep,obj.var.audio_src(ii).name]);
                 end
             end
                                                        
            audio_info = audioinfo(char(files(1)));
         
            SAD = [];
            
            c = parcluster();
            a = 0;
            
            numCores = feature('numCores');
            answer = '';
                while ~isnumeric(answer) || answer > numCores
                    prompt = ['There are ' , num2str(numCores) , ' cores available. How many cores do you want to use?'];
                    dlg_title = 'Number of using Cores';
                    num_lines = 1;
                    def = {num2str(numCores-1)};
                    answer = inputdlg(prompt,dlg_title,num_lines,def);
                    
                    if isempty(answer)
                        return;
                    end
                    try
                        answer = str2num(cell2mat(answer));
                    catch
                    end
                end

            global conf;
            config;
            
            
            loading_frames = ceil((audio_info.TotalSamples - (beginning_sample-1))/ answer);
            
            % Initialize Batch Jobs
            for ii=1:answer
                if ~obj.var.sad_canceled
                    start_sample = beginning_sample+(loading_frames*(ii-1))-(obj.var.frame_len-obj.var.frame_shift)*a;
                    end_sample = loading_frames*ii + beginning_sample;
                    if end_sample > audio_info.TotalSamples
                        end_sample = audio_info.TotalSamples;
                    end
                    
                    obj.var.job_SAD(ii) = batch(c,@calc_SAD,1,{files,start_sample,end_sample,conf});
                    a = 1;
                    % pause is necessary if user wants to cancel sad
                    % recognition. otherwise callback doesn't execute
                    pause(.1);
                else
                    for jj=1:length(obj.var.job_SAD)
                        obj.var.job_SAD(jj).cancel;
                    end
                    delete(obj.var.job_SAD);
                    return;
                end
            end
            obj.handles.dialog_string.String = 'Automatic SAD Recognition is running.  ';
            counter = 1;
            while strcmp(obj.var.job_SAD(1).State,'running') && ~obj.var.sad_canceled
                % Plot dots during processing...
                pointval = mod(counter,6);
                if pointval < 2
                    obj.handles.dialog_string.String = 'Automatic SAD Recognition is running.  ';
                elseif pointval < 4 
                    obj.handles.dialog_string.String = 'Automatic SAD Recognition is running.. ';
                else
                    obj.handles.dialog_string.String = 'Automatic SAD Recognition is running...';
                end
                pause(0.1);
                counter = counter + 1;
            end
            if obj.var.sad_canceled
                obj.handles.dialog_string.String = 'Automatic SAD Recognition will be canceled.';
                for ii=1:answer
                    obj.var.job_SAD(ii).cancel;
                end
                delete(obj.var.job_SAD);
                return;
            end
        
            % Get Data from Batch Jobs
            for ii=1:answer
                wait(obj.var.job_SAD(ii));
                r = fetchOutputs(obj.var.job_SAD(ii));
                SAD = [SAD;r{1}];
            end
            delete(obj.var.job_SAD);
            
            if beginning_sample ~=1
                prepending_SAD = zeros(beginning_sample/obj.var.frame_shift,size(SAD,2));
                SAD = [prepending_SAD;SAD];
            end
            SAD = get_turns(SAD);
            SAD = logical(SAD);
            
            save([obj.var.dbdir,filesep,'.tmp\SAD.mat'],'SAD');
            obj.var.SAD_exist = true;
   
            set(obj.handles.vad_button,'BackgroundColor', obj.darkergrey);
            set(obj.handles.vad_button,'ShadowColor', obj.darkergrey);
            set(obj.handles.vad_button,'HighlightColor', obj.darkergrey);
            
        end
        
        %% init_mute_panels
        function init_mute_panels(obj)
            obj.update_msg_block('Initialize Mute Panels');
            for ii=1:length(obj.audio.speaker)
             set(obj.handles.mute_panel(ii),'ButtonDownFcn', @obj.callback_mute);
             set(obj.handles.mute_panel(ii),'BackgroundColor', obj.blue);
             set(obj.handles.mute_panel(ii),'HighlightColor', obj.blue);
             set(obj.handles.mute_panel(ii),'ShadowColor', obj.blue);
             obj.handles.mute_panel(ii).UserData.Channel = ii;
            end
        end
        
        %% init_solo_panels
        function init_solo_panels(obj)
            obj.update_msg_block('Initialize Solo Panels');
            for ii=1:length(obj.audio.speaker)
             set(obj.handles.solo_panel(ii),'ButtonDownFcn', @obj.callback_solo);
             set(obj.handles.solo_panel(ii),'BackgroundColor', obj.blue);
             set(obj.handles.solo_panel(ii),'HighlightColor', obj.blue);
             set(obj.handles.solo_panel(ii),'ShadowColor', obj.blue);
             obj.handles.solo_panel(ii).UserData.Channel = ii;
            end
        end
        
        %% init_time_strings
        function init_time_strings(obj)
            obj.update_msg_block('Initialize Time String');
            
            if ~isempty(obj.var.video_src)
                obj.var.video_info = mmfileinfo([obj.video.file.Path, filesep, obj.video.file.Name]);
                totaltime = datevec(obj.var.video_info.Duration/86400);
            else
                obj.var.audio_info = audioinfo([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, obj.var.audio_src(1).name]);
                totaltime = datevec(obj.var.audio_info.Duration/86400);
            end
            
            obj.handles.total_time_str.String = sprintf('%02.0f:%02.0f:%02.0f:%03.0f', totaltime(4), totaltime(5), fix(totaltime(6)), fix((totaltime(6)-fix(totaltime(6)))*1000));
            obj.update_time_string();
        end
        
        %% init_time_on_axes
        function init_time_on_axes(obj)
            obj.update_msg_block('Initialize XTick Labels');
            obj.handles.soundwave_axes(end).XTick = 1:5*obj.var.fs/obj.var.qp:(obj.var.audio_info.Duration*obj.var.fs/obj.var.qp);
            for ii=1:length(obj.handles.soundwave_axes(end).XTick)
                time = datevec((obj.handles.soundwave_axes(end).XTick(ii) * obj.var.qp/obj.var.fs + obj.var.delay_in_sec)/86400);
                obj.handles.soundwave_axes(end).XTickLabel(ii) = cellstr(sprintf('%02.0f:%02.0f:%02.0f:%03.0f', time(4), time(5), fix(time(6)), fix((time(6)-fix(time(6)))*1000)));
            end
            label = get(obj.handles.soundwave_axes(end),'XTickLabel');
            set(obj.handles.soundwave_axes(end),'XTickLabel',label,'FontSize',8)
        end
        
        %% init_time_slider
        function init_time_slider(obj)
            obj.update_msg_block('Initialize Time Slider');
            obj.var.audio_info = audioinfo([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, obj.var.audio_src(1).name]);
            max_value = obj.var.audio_info.TotalSamples/obj.var.qp;
            obj.handles.time_slider.Value = 1;
            obj.handles.time_slider.Max = max_value;
            obj.handles.time_slider.Min = 1;
            obj.handles.time_slider.Enable = 'On';
            obj.handles.time_slider.Visible = 'On';
            obj.handles.time_slider.SliderStep = [0.0001 .001];
            addlistener(obj.handles.time_slider,'ContinuousValueChange',@obj.callback_time_slider);
            set(obj.handles.time_slider,'Callback',@obj.release_time_slider);
        end
        
        %% init_videoreader
        % reads the video file and converted the video if there is no
        % converted video yet and the user want it to convert.
        function init_videoreader(obj)
            obj.update_msg_block('Initialize Video Reader');
            obj.var.video_src = [dir(fullfile(obj.var.dbdir,filesep,obj.name_of_tmp_folder,filesep, '*.wmv'));...
                                 dir(fullfile(obj.var.dbdir,filesep,obj.name_of_tmp_folder,filesep, '*.avi'));...
                                 dir(fullfile(obj.var.dbdir,filesep,obj.name_of_tmp_folder,filesep, '*.mp4'))];
                             
             if ~isempty( obj.var.video_src)
                 obj.var.folder_of_video_src = obj.name_of_tmp_folder;
                 obj.video.file = VideoReader([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, obj.var.video_src.name]);
                 obj.var.frames_per_second = obj.video.file.FrameRate;
                 obj.handles.video_checkbox.Enable = 'on';
                 return;
             end
             
             obj.var.video_src = [dir(fullfile(obj.var.dbdir, '*.wmv'));...
                 dir(fullfile(obj.var.dbdir, '*.avi'));...
                 dir(fullfile(obj.var.dbdir, '*.mp4'))];

            if isempty(obj.var.video_src)
                msgbox('No Video file found!','Message','modal');
                obj.handles.video_checkbox.Value = 0;
                obj.handles.video_checkbox.Enable = 'off';
                if ~isempty(obj.video)
                    imshow(readFrame(obj.video.file).*0+256, 'Parent',obj.handles.video_axes);
                    obj.var.folder_of_video_src = '';
                end
                return;
            end
                     
            choice = questdlg('The Video is not converted yet! Do you want to convert now? (Takes some time)', ...
                'Video is not converted yet!','Yes', ...
                'No','Yes');

            switch choice
                case 'Yes'
                    obj.update_msg_block('Converting Video. This takes some time.');
                    system([pwd,filesep,'bin/ffmpeg',filesep,'ffmpeg',' -i "',obj.var.dbdir, filesep, obj.var.video_src.name, '" -vf scale=176:-1 "',obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep,obj.var.video_src.name(1:end-4),'_converted.wmv"']);
                    obj.init_videoreader();
                case 'No'
                    obj.video.file = VideoReader([obj.var.dbdir, filesep, obj.var.video_src(1).name]);
                    obj.var.frames_per_second = obj.video.file.FrameRate;
            end
            obj.handles.video_checkbox.Enable = 'on';
        end
        
        %% init_key
        % reads the desired *.txt key file
        function init_key(obj, hObject, eventData)
            set(obj.handles.key_button,'BackgroundColor', obj.red);
            set(obj.handles.key_button,'ShadowColor', obj.red);
            set(obj.handles.key_button,'HighlightColor', obj.red);
            
            obj.var.keys = dir(fullfile('./keys/', '*.txt'));
            
            if size(obj.var.keys,1) > 1
                file_list = {obj.var.keys.name}';
                [s,v] = listdlg('PromptString','Select a key file:',...
                    'SelectionMode','single',...
                    'ListString',file_list);
                if v
                    filename = file_list(s);
                else
                    filename = obj.var.keys(1).name;
                end
            else
                filename = obj.var.keys(1).name;
            end
            obj.handles.keyname_str.String = ['Loaded Key: ',char(filename)];
            
            [input, output, class]=textread(['./keys/',char(filename)],'%s %s %s'); %#ok<DTXTRD>
            output = strrep(output,'_',' ');
            class = strrep(class,'_',' ');
            obj.var.lookuptable = [input, output, class];
            
            set(obj.handles.key_button,'BackgroundColor', obj.blue);
            set(obj.handles.key_button,'ShadowColor', obj.blue);
            set(obj.handles.key_button,'HighlightColor', obj.blue);
        end
        
        %% init_var
        function init_var(obj)
            obj.var.start_sample = 1;
            obj.var.is_playing = false;
            obj.var.vad_is_playing = false;
            obj.var.test = 0;
            obj.var.not_plotted = true;
            obj.var.offset = 0;
            obj.var.vad_tagged = [0 0];
            obj.var.lvl2_nr = 0;
            obj.var.audio_loaded = false;
            obj.var.no_audio = false;
            % frames per second for old version  of  Excel-onset/offset values (default
            % 25):
            obj.var.frames_per_second = 25;
            
            % Is not determined until now.
            obj.var.delay_in_sec = NaN;
            obj.var.delay_in_sample = NaN;
            
            obj.var.folder_of_video_src = '';
            
            global conf
            config;
            obj.var.frame_len = conf.frame_len;
            obj.var.frame_shift = conf.frame_shift;
            obj.var.goal_fs = conf.fs;
            clear conf;
            
            obj.var.loading_frames = obj.var.frame_len * 5625 * 2;
        end
        
        %% init_autosave_timer
        function init_autosave_timer(obj)
           obj.update_msg_block('Initialize Autosave Timer');
           obj.handles.autosave_timer = timer('TimerFcn',@obj.callback_export_to_excel,...
                                              'StartDelay',30,...
                                              'Period',60,...
                                              'ExecutionMode','fixedSpacing',...
                                              'Tag','Autosave');
        end        
     
        %% update_soundwave_plot_zoom
        function update_soundwave_plot_zoom(obj)
            mouse_pos = get(obj.handles.soundwave_axes(1), 'currentpoint');
            x_mouse = mouse_pos(1,1);
            for ii=1:length(obj.audio.speaker)
                obj.handles.soundwave_axes(ii).XLim = [x_mouse-obj.var.q_reference/obj.var.qp*obj.show_seconds ...
                    x_mouse+obj.var.q_reference/obj.var.qp*obj.show_seconds];
                obj.handles.time_cursor_axes.XLim = obj.handles.soundwave_axes(1).XLim;
            end
        end
        
        %% update_soundwave_plot
        % update the position of the time cursor and the view if
        % the time cursor is beyond the current view
        function update_soundwave_plot(obj)
            if obj.handles.timer_cursor.XData(1) >= obj.handles.soundwave_axes(1).XLim(2)
                obj.handles.time_cursor_axes.XLim = [obj.handles.time_cursor_axes.XLim(2) obj.handles.time_cursor_axes.XLim(2)+obj.var.q_reference/obj.var.qp*obj.show_seconds];
                for ii=1:length(obj.audio.speaker)
                    obj.handles.soundwave_axes(ii).XLim = obj.handles.time_cursor_axes.XLim;
                end
                
            end
            
            obj.var.last_position = obj.handles.timer_cursor.XData(1);
            tic;
            CurrentSamplePlot = round((obj.audio.reference.CurrentSample+obj.var.offset) * 1/obj.var.qp);
            set(obj.handles.timer_cursor,'XData', [CurrentSamplePlot+round(toc*obj.var.p) CurrentSamplePlot+round(toc*obj.var.p)]);
            drawnow;
        end
        
        %% update_video_frame
        function update_video_frame(obj)
            if strcmp(obj.audio.reference.Running,'on')
               CurrentSample = obj.audio.reference.CurrentSample;
            else
               CurrentSample = obj.var.start_sample; 
            end
             
            CurrentTime = (CurrentSample + obj.var.offset + obj.var.delay_in_sample)/obj.audio.reference.SampleRate;
            obj.video.file.CurrentTime = CurrentTime;
%             showFrameOnAxis(obj.handles.video_axes, readFrame(obj.video.file));
            imshow(readFrame(obj.video.file), 'Parent',obj.handles.video_axes);
        end
        
        %% update_text_plot
        function update_text_plot(obj)
           code = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Code;
           if ~isempty(strtrim(char(obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Memo)))
              code = strcat(char(code),'*');       
           end
           obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).TextObject.String = char(code);
        end
        
        %% update_time_slider
        function update_time_slider(obj)
            obj.handles.time_slider.Value = obj.handles.timer_cursor.XData(1);
        end
        
        %% update_playing_speakers
        function update_playing_speakers(obj)
            solo_active = false;
            for ii=1:length(obj.audio.speaker)
               if obj.audio.speaker(ii).UserData.Solo
                   solo_active = true;
                   break;
               end
            end
            
            for ii=1:length(obj.audio.speaker)
               if obj.audio.speaker(ii).UserData.Muted
                   obj.audio.speaker(ii).UserData.On = false;
                   obj.handles.soundwave_axes(ii).Color = [.7 .7 .7];
               else
                   if solo_active && obj.audio.speaker(ii).UserData.Solo
                       obj.audio.speaker(ii).UserData.On = true;
                       obj.handles.soundwave_axes(ii).Color = [1 1 1];
                   elseif solo_active && ~obj.audio.speaker(ii).UserData.Solo
                       obj.audio.speaker(ii).UserData.On = false;
                       obj.handles.soundwave_axes(ii).Color = [.7 .7 .7];
                   else
                       obj.audio.speaker(ii).UserData.On = true;
                       obj.handles.soundwave_axes(ii).Color = [1 1 1];
                   end
               end
            end
        end
        
        %% first_trace_with_vad_in_view
        function trace = first_trace_with_vad_in_view(obj, direction)
            trace = obj.var.vad_tagged(1);
            range = obj.handles.time_cursor_axes.XLim;
            if strcmp(direction, 'up')
                for ii=trace-1:-1:1
                    vad_nr = obj.find_first_vad_in_view(ii);
                    if isempty(vad_nr)
                        continue;
                    end
                    left_vad_bound = obj.audio.data(ii).vad(vad_nr).PlotData(1);
                    right_vad_bound = obj.audio.data(ii).vad(vad_nr).PlotData(2);
                    if  (left_vad_bound > range(1) && left_vad_bound < range(2))% || right_vad_bound < range(2)
                       trace = ii;
                       return;
                    end
                end
            elseif strcmp(direction, 'down')
                for ii=trace+1:length(obj.audio.speaker)
                    vad_nr = obj.find_first_vad_in_view(ii);
                    if isempty(vad_nr)
                        continue;
                    end
                    left_vad_bound = obj.audio.data(ii).vad(vad_nr).PlotData(1);
                    right_vad_bound = obj.audio.data(ii).vad(vad_nr).PlotData(2);
                    if  (left_vad_bound > range(1) && left_vad_bound < range(2))% || right_vad_bound < range(2)
                       trace = ii;
                       return;
                    end
                end
            end
        end
        
        %% update_time_string
        function update_time_string(obj)
            CurrentTime = datevec((obj.audio.reference.CurrentSample+obj.var.offset + obj.var.delay_in_sample)/obj.audio.reference.SampleRate/86400);
            obj.handles.current_time_str.String = sprintf('%02.0f:%02.0f:%02.0f:%03.0f', CurrentTime(4), CurrentTime(5), fix(CurrentTime(6)), fix((CurrentTime(6)-fix(CurrentTime(6)))*1000) );
        end
        
        %% extend_soundwave_plot
        function extend_soundwave_plot(obj)       
            for ii=1:length(obj.audio.speaker)  
                obj.update_msg_block(['Plotting Audio Track ',num2str(ii)]);
                obj.audio.data(ii).samples_plot = obj.audio.data(ii).samples_plot(1:obj.var.qp:end);
                
                obj.audio.data(ii).samples_plot = single(obj.audio.data(ii).samples_plot);
                   
                delete(obj.handles.soundwave(ii));
        
                start_x = round(obj.audio.speaker(ii).UserData.SampleRange(1)*1/obj.var.qp);
                end_x = round(obj.audio.speaker(ii).UserData.SampleRange(2)*1/obj.var.qp);

                t = start_x:1:end_x;
                if length(t) > length(obj.audio.data(ii).samples_plot)
                    t = t(1:length(obj.audio.data(ii).samples_plot));
                else
                    obj.audio.data(ii).samples_plot = obj.audio.data(ii).samples_plot(1:length(t));
                end
                
                obj.handles.soundwave(ii) = plot(obj.handles.soundwave_axes(ii),t',obj.audio.data(ii).samples_plot,'Color','b');
                obj.handles.soundwave_axes(ii).Children = obj.handles.soundwave_axes(ii).Children([2:1:length(obj.handles.soundwave_axes(ii).Children) 1]);
                set(obj.handles.soundwave(ii), 'ButtonDownFcn', @obj.callback_axes);
                  
            end
        end
        
        %% remove_vads_of_old_roi
        % removes VADs which are in the old region of interest
        function remove_vads_of_old_roi(obj)
            range = [obj.handles.soundwave(1).XData(1) obj.handles.soundwave(1).XData(end)];
            
            start_points = [];
            vad = [];
            log = strncmp(fieldnames(obj.audio.data),'vad',3);
            if sum(log) > 0
                for ii=1:length(obj.audio.speaker)
                    if ~isempty(obj.audio.data(ii).vad)
                        start_points = [start_points, obj.audio.data(ii).vad.PlotData];
                        vad = [vad, obj.audio.data(ii).vad];
                    end
                end
            else
                return;
            end
            start_points = start_points(1,:);
            
            [start_points, i] = sort(start_points);
            vad = vad(i);
            
            idx_low = find(start_points > range(1)); 
            idx_high = find(start_points < range(2)); 
            
            if ~isempty(idx_low) && ~isempty(idx_high)
                idx_low = idx_low(1);
                idx_high = idx_high(end);
                
                for ii=idx_low:idx_high
                    ID = vad(ii).Object.UserData.ID;
                    userdata = obj.audio.data(ID(1)).vad(ID(2)).Object.UserData;
                    if isa(obj.audio.data(ID(1)).vad(ID(2)).Object,'matlab.graphics.primitive.Patch')
                        delete(obj.audio.data(ID(1)).vad(ID(2)).Object);
                    end
                    obj.audio.data(ID(1)).vad(ID(2)).Object = [];
                    obj.audio.data(ID(1)).vad(ID(2)).Object.UserData = userdata;
                    delete(obj.audio.data(ID(1)).vad(ID(2)).TextObject);
                end
            end
        end
        
        %% plot_vads_of_roi
        % plots VADs which are in the new region of interest
        function plot_vads_of_roi(obj)
            range = [obj.handles.soundwave(1).XData(1) obj.handles.soundwave(1).XData(end)];
            zdata = zeros(4,1);
            
            start_points = [];
            vad = [];
            log = strncmp(fieldnames(obj.audio.data),'vad',3);
            if sum(log) > 0
                for ii=1:length(obj.audio.speaker)
                    if ~isempty(obj.audio.data(ii).vad)
                        start_points = [start_points, obj.audio.data(ii).vad.PlotData];
                        vad = [vad, obj.audio.data(ii).vad];
                    end
                end
            else
                return;
            end            
            start_points = start_points(1,:);
            
            [start_points, i] = sort(start_points);
            vad = vad(i);
            
            idx_low = find(start_points > range(1)); 
            idx_high = find(start_points < range(2));
            
            if ~isempty(idx_low) && ~isempty(idx_high)
                idx_low = idx_low(1);
                idx_high = idx_high(end);
                for ii=idx_low:idx_high
                    ID = vad(ii).Object.UserData.ID;
                    y = obj.handles.soundwave_axes(ID(1)).YLim(2);
                    ydata = [y; y; -y; -y];
                    userdata = obj.audio.data(ID(1)).vad(ID(2)).Object.UserData;
                    xdata = obj.audio.data(ID(1)).vad(ID(2)).PlotData;
                    
                    if isempty(obj.audio.data(ID(1)).vad(ID(2)).Code)
                        color = obj.yellow;
                    else
                        color = obj.green;
                    end
                    
                    code = obj.audio.data(ID(1)).vad(ID(2)).Code;
                    if ~isempty(obj.audio.data(ID(1)).vad(ID(2)).Memo)
                        code = strcat(char(code),'*'); 
                    else
                        code = char(code);
                    end
                    
                    obj.audio.data(ID(1)).vad(ID(2)).Object = patch(xdata,ydata,zdata,'parent',obj.handles.soundwave_axes(ID(1)),'FaceColor', color, 'FaceAlpha' , 0.3);
                    obj.audio.data(ID(1)).vad(ID(2)).TextObject = text(xdata(1),double(y*1.1),code,'Parent',obj.handles.soundwave_axes(ID(1)),'FontSize',8,'Interpreter','none');
                    obj.audio.data(ID(1)).vad(ID(2)).Object.UserData = userdata;
                    set(obj.audio.data(ID(1)).vad(ID(2)).Object, 'ButtonDownFcn', @obj.callback_axes);
                end
            end
        end
        
        %% time_to_sample_in_plot
        % convert the Onset/Offset time into the place within the plot
        function sample = time_to_sample_in_plot(obj, time)
            sample = ((time*10^-7 - obj.var.delay_in_sec) * obj.var.fs * 1/obj.var.qp) + 1;
        end
        
        %% sample_in_plot_to_time
        % convert the place within the plot into the Onset/Offset Time
        function time = sample_in_plot_to_time(obj, sample)
            time = round((((sample-1) * 1/obj.var.fs * obj.var.qp) + obj.var.delay_in_sec ) * 10^7);
        end
        
        %% find_delay
        % Determine the Delay between AudioFiles and VideoFile
        function find_delay(obj)
            obj.update_msg_block('Finding Delay between Video and Audio!');
            
            if isempty(obj.var.video_src) || obj.var.no_audio
                obj.var.delay_in_sample = 0;
                obj.var.delay_in_sec = 0;
                return;
            end
            
            vidaud_info = audioinfo([obj.video.file.Path,filesep,obj.video.file.Name]);
            aud_info = audioinfo([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, obj.var.audio_src(1).name]);
            fs_vidaud = vidaud_info.SampleRate;
            fs_aud = vidaud_info.SampleRate;
            if 5*60*fs_vidaud > vidaud_info.TotalSamples
                duration_vidaud = vidaud_info.Duration;
            else
                duration_vidaud = 5*60;
            end
            if duration_vidaud*fs_aud > aud_info.TotalSamples
                duration_vidaud = aud_info.Duration;
            end
            
            [vidaud, fs_vidaud] = audioread([obj.video.file.Path,filesep,obj.video.file.Name],[1 duration_vidaud*fs_vidaud]);
            [aud, fs_aud] = audioread([obj.var.dbdir, filesep,obj.name_of_tmp_folder,filesep, obj.var.audio_src(1).name],[1 duration_vidaud*fs_aud]);
            if fs_vidaud ~= fs_aud
                [d,n] = rat(fs_aud/fs_vidaud);
                vidaud = resample(vidaud,d,n);
                vidaud = vidaud(1:length(aud));
            end    
            [acor,lag] = xcorr(vidaud,aud);
            [~,I] = max(abs(acor));
            obj.var.delay_in_sample = lag(I);
            obj.var.delay_in_sec = obj.var.delay_in_sample/fs_aud;
        end

        %% sort_vads
        % sorts the VAD in the order of occurence within the AudioTrace and
        % removes deleted ones.
        function sort_vads(obj, speaker, vad_nr)
            if nargin > 2
                Onset = obj.audio.data(speaker).vad(vad_nr).Onset;
            elseif nargin == 1
                speaker = 1:length(obj.audio.speaker);
            else
                Onset = 0;
            end
            
            for jj=1:length(speaker)
                obj.audio.data(speaker(jj)).vad = obj.audio.data(speaker).vad(~[obj.audio.data(speaker(jj)).vad.Deleted]);
                Onsets = [obj.audio.data(speaker(jj)).vad.Onset];
                
                [Onsets,idx] = sort(Onsets);
                
                if Onset ~=0
                    new_vad_nr = find(Onset == Onsets);
                    obj.var.vad_tagged = [speaker(jj) new_vad_nr];
                end
                
                obj.audio.data(speaker(jj)).vad = obj.audio.data(speaker(jj)).vad(idx);
                for ii=1:length(obj.audio.data(speaker(jj)).vad)
                    obj.audio.data(speaker(jj)).vad(ii).Object.UserData.ID = [speaker(jj) ii];
                end
            end
        end
        
        %% split_codestring_into_cell
        function code = split_codestring_into_cell(obj, str)
            indices = strfind(str,';');      
                    if ~isempty(indices)
                        code = cellstr(str(1:indices(1)-1));
                        for jj=1:length(indices)
                            
                            if jj ~= length(indices)
                                code(jj+1) = cellstr(strtrim(str(indices(jj)+1:indices(jj+1)-1)));
                            else
                                code(jj+1) = cellstr(strtrim(str(indices(jj)+1:end)));
                            end
                        end
                    else
                        code = cellstr(str);
                    end
        end
        
        %% is_tagged_vad_in_range
        function is_tagged_vad_in_range(obj)
            range = [obj.handles.soundwave(1).XData(1) obj.handles.soundwave(1).XData(end)];
            xdata = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).PlotData;
            
            if xdata(1) < range(2) && xdata(1) > range(1)
                obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Object.FaceColor = obj.red;
            else
                obj.var.vad_tagged = [0 0];
            end
        end
        
        %% set_info_text_at_loading
        function block_msg_cleanup = set_info_text_at_loading(obj)
            jFigPeer = get(handle(obj.handles.fig),'JavaFrame');
            % figure out what kind of FigureClient has to be used (depends
            % on Matlab Version?)
            str = char(jFigPeer.getParentFigureValidator);
            [start_idx, end_idx] = regexp(str,'HG\d+');
            if isempty(start_idx)
                jWindow = jFigPeer.fFigureClient.getWindow;
            else
                jWindow = jFigPeer.(['f',str(start_idx:end_idx),'Client']).getWindow;
            end
            msg_str = ['<HTML><FONT color="#000000" size=5><center>'...
               'Loading may take a long time!</center></FONT></HTML>'];
           
           [obj.var.block_msg, block_msg_cont] = javacomponent('javax.swing.JLabel',[100,200,200,30]);
           set(obj.var.block_msg,'text',msg_str);
           obj.var.block_msg.Background = java.awt.Color(0.7804, 0.7804, 0.7804);
           
           % set block message central on screen
           set(block_msg_cont,'Units', 'normalized');
           set(block_msg_cont,'Position',[0.425, 0.425, .2, .2]);
           set(block_msg_cont,'Units', 'Centimeters');
           pos = get(block_msg_cont, 'Position');
           set(block_msg_cont,'Position',[pos(1:2) 6, 3.5]);
           drawnow;
           
           block_msg_cleanup = onCleanup(@()obj.delete_msg_block(obj.var.block_msg, jWindow)); 
        end
        
        %% delete_msg_block
        function delete_msg_block(obj, block_msg, jWindow)
            delete(block_msg);
            jWindow.setEnabled(true);
        end
        
        %% update_msg_block
        function update_msg_block(obj, string)
            msg_str = ['<HTML><FONT color="#000000" size=5><center>'...
               ,string,'</center></FONT></HTML>'];
            set(obj.var.block_msg,'text',msg_str);
        end
        
        %% convert_excel_to_old_version
        % converts a whole excel table to the old Onset/Offset version
        function converted_excel = convert_excel_to_old_version(obj, excel)
            header = excel(1,:);
            converted_excel = excel;
            
            idx_level = strncmp(header, 'Level',5);
            idx_onset = strncmp(header, 'Onset',5);
            idx_offset = strncmp(header, 'Offset',6);
            converted_excel(1,idx_level) = cellstr('Type');
            converted_excel(1,idx_onset) = cellstr('Entry');
            converted_excel(1,idx_offset) = cellstr('Exit');
                       
            for ii=2:size(excel,1)
                if cell2mat(excel(ii,idx_level)) == 3
                    converted_excel(ii,idx_level) = cellstr('E');
                elseif cell2mat(excel(ii,idx_level)) == 2
                    converted_excel(ii,idx_level) = cellstr('T');
                elseif cell2mat(excel(ii,idx_level)) == 1
                    converted_excel(ii,idx_level) = cellstr('S');
                end
                timevec = datevec(cell2mat(excel(ii,2))*10^-7/86400);
                converted_excel(ii,2) = cellstr(sprintf('%02.0f:%02.0f:%02.0f:%02.0f', timevec(4), timevec(5), fix(timevec(6)), floor(obj.var.frames_per_second*(timevec(6)-fix(timevec(6))))));
                timevec = datevec(cell2mat(excel(ii,3))*10^-7/86400);
                converted_excel(ii,3) = cellstr(sprintf('%02.0f:%02.0f:%02.0f:%02.0f', timevec(4), timevec(5), fix(timevec(6)), floor(obj.var.frames_per_second*(timevec(6)-fix(timevec(6))))));                
            end
            
            
        end
        
        %% convert_oldversion_time_to_new
        % converts a old Onset/Offset version to the new one
        function time = convert_oldversion_time_to_new(obj, timestring)
            splitted = strsplit(timestring,':');
            time = (str2num(splitted{1})*3600 + str2num(splitted{2})*60 + str2num(splitted{3}) + str2num(splitted{4})/obj.var.frames_per_second)*10^7;
        end
        
        %%
        function check_current_audio_buffer(obj)
            old_range = [obj.handles.soundwave(1).XData(1) obj.handles.soundwave(1).XData(end)];
            vad_boundaries(1) = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Onset;
            vad_boundaries(2) = obj.audio.data(obj.var.vad_tagged(1)).vad(obj.var.vad_tagged(2)).Offset;
            vad_boundaries = obj.time_to_sample_in_plot(vad_boundaries);
            
            if vad_boundaries(1) > old_range(1) && vad_boundaries(2) < old_range(2)
                return;
            end
            obj.handles.timer_cursor.XData = [vad_boundaries(1) vad_boundaries(1)];
            CurrentTime = datevec(round(obj.handles.timer_cursor.XData(1) *obj.var.qp + obj.var.delay_in_sample)/obj.audio.reference.SampleRate/86400);
            obj.handles.current_time_str.String = sprintf('%02.0f:%02.0f:%02.0f:%03.0f', CurrentTime(4), CurrentTime(5), fix(CurrentTime(6)), fix((CurrentTime(6)-fix(CurrentTime(6)))*1000) );
            obj.update_time_slider();
            obj.set_reference_new_with_timecursor();
            drawnow;
            if obj.handles.video_checkbox.Value
                obj.update_video_frame();
            end
        end
                
    end %end of methods
end % end of classdef