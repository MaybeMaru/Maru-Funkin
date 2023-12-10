package funkin.states;

import funkin.objects.funkui.FunkDropDown;
import funkin.objects.funkui.FunkInputText;
import funkin.objects.funkui.FunkCheckBox;
import funkin.objects.funkui.FunkUIContainer;
import funkin.objects.funkui.FunkButton;

class TestStateUI extends MusicBeatState {
    var container:FunkUIContainer;
    
    public function new() {
        super();
        
        container = new FunkUIContainer(100, 100, 800, 400);
        container.setDisplacement(10,10);
        add(container);
        
        for (i in 0...8) {
            container.add(new FunkButton(0, 50 * i, "abcabc", function () {
                trace("clicked " + i);
            }));
        }

        for (i in 0...8) {
            container.add(new FunkCheckBox(200, 50 * i, "abcabc", function (bool) {
                trace("turned check " + i + " to " + bool);
            }));
        }

        for (i in 0...2) {
            container.add(new FunkInputText(350, 100 * i, "", null, 4));
        }

        for (i in 0...1) {
            container.add(new FunkDropDown(350, 200 + 50 * i));
        }
        
    }
}