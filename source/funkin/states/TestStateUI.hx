package funkin.states;

import funkin.objects.funkui.*;

class TestStateUI extends MusicBeatState {
    var container:UIContainer;
    
    public function new() {
        super();
        
        container = new UIContainer(100, 100, 800, 400);
        container.setDisplacement(10,10);
        add(container);
        
        for (i in 0...8) {
            container.add(new Button(0, 50 * i, "abcabc", function () {
                trace("clicked " + i);
            }));
        }

        for (i in 0...8) {
            container.add(new CheckBox(200, 50 * i, "abcabc", function (bool) {
                trace("turned check " + i + " to " + bool);
            }));
        }

        for (i in 0...2) {
            container.add(new InputText(350, 100 * i, "", null, 4));
        }

        for (i in 0...2) {
            container.add(new DropDown(350 + 150 * i, 200, i == 0 ? ["Test1", "Test2", "Test3"] : ["Test4", "Test5", "Test6"]));
        }
        
    }
}