classdef MainGUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        SpatialresolutionButtonGroup    matlab.ui.container.ButtonGroup
        kmButton_3                      matlab.ui.control.ToggleButton
        kmButton_2                      matlab.ui.control.ToggleButton
        kmButton                        matlab.ui.control.ToggleButton
        TemporalresolutiondayEditField  matlab.ui.control.NumericEditField
        TemporalresolutiondayEditFieldLabel  matlab.ui.control.Label
        StartButton                     matlab.ui.control.Button
        DatePicker                      matlab.ui.control.DatePicker
        DatePickerLabel                 matlab.ui.control.Label
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 317 278];
            app.UIFigure.Name = 'MATLAB App';

            % Create DatePickerLabel
            app.DatePickerLabel = uilabel(app.UIFigure);
            app.DatePickerLabel.HorizontalAlignment = 'right';
            app.DatePickerLabel.Position = [52 221 68 22];
            app.DatePickerLabel.Text = 'Date Picker';

            % Create DatePicker
            app.DatePicker = uidatepicker(app.UIFigure);
            app.DatePicker.Position = [135 221 150 22];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.Position = [71 33 100 22];
            app.StartButton.Text = 'Start';

            % Create TemporalresolutiondayEditFieldLabel
            app.TemporalresolutiondayEditFieldLabel = uilabel(app.UIFigure);
            app.TemporalresolutiondayEditFieldLabel.HorizontalAlignment = 'right';
            app.TemporalresolutiondayEditFieldLabel.Position = [52 185 140 22];
            app.TemporalresolutiondayEditFieldLabel.Text = 'Temporal resolution [day]';

            % Create TemporalresolutiondayEditField
            app.TemporalresolutiondayEditField = uieditfield(app.UIFigure, 'numeric');
            app.TemporalresolutiondayEditField.Position = [203 185 57 22];

            % Create SpatialresolutionButtonGroup
            app.SpatialresolutionButtonGroup = uibuttongroup(app.UIFigure);
            app.SpatialresolutionButtonGroup.Title = 'Spatial resolution';
            app.SpatialresolutionButtonGroup.Position = [53 72 123 106];

            % Create kmButton
            app.kmButton = uitogglebutton(app.SpatialresolutionButtonGroup);
            app.kmButton.Text = '25 km';
            app.kmButton.Position = [11 53 100 22];
            app.kmButton.Value = true;

            % Create kmButton_2
            app.kmButton_2 = uitogglebutton(app.SpatialresolutionButtonGroup);
            app.kmButton_2.Text = '12.5 km';
            app.kmButton_2.Position = [11 32 100 22];

            % Create kmButton_3
            app.kmButton_3 = uitogglebutton(app.SpatialresolutionButtonGroup);
            app.kmButton_3.Text = '9 km';
            app.kmButton_3.Position = [11 11 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MainGUI_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end