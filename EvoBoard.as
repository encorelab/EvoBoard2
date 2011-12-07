package
{
	//This is the evoboard application for step 1 of the biodiversity run in Nov/Dec 2011
	
	import classes.GuessTable;
	import classes.OrganismTag;
	import classes.OrganismVis;
	import classes.RankTable;
	import classes.RationaleTable;
	
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public class EvoBoard extends Sprite
	{
		private var debugging:Boolean = true;
		private var screen_height:Number = 768;
		private var screen_width:Number = 1024;
		public var event_debug:DebugText;
		public var organism_vis:OrganismVis;
		public var guess_table:GuessTable;
		public var rank_table:RankTable;
		public var rationale_table:RationaleTable;
		
		public function EvoBoard()
		{
			if ( debugging ){
				event_debug = new DebugText();
				addChild( event_debug ); 
				event_debug.debug_txt.text = "Waiting for event...";
			}
			ExternalInterface.addCallback("sevToFlash", handleSev);
			
			setupEvoBoard();
		}	
		
		public function setupEvoBoard():void{
			//for STEP1
			organism_vis = new OrganismVis();
			addChild( organism_vis );
			
			//for STEP2
			guess_table = new GuessTable();
			addChild( guess_table );
			
			//for STEP4 ranking
			rank_table = new RankTable();
			addChild( rank_table );
			
			//for STEP4 rationales
			rationale_table = new RationaleTable();
			addChild( rationale_table );
			organism_vis.visible = false;
			guess_table.visible = false;
			rank_table.visible = false;
			rationale_table.visible = false;
			stage.addEventListener( KeyboardEvent.KEY_DOWN, reportKeyDown );
		}
		
		private function reportKeyDown( event:KeyboardEvent ):void
		{
			//event_debug.appendText("Key Pressed: " + String.fromCharCode(event.charCode) + " (key code: " + event.keyCode + " character code: " + event.charCode + ")");
			trace("Key Pressed: " + String.fromCharCode(event.charCode) + " (key code: " + event.keyCode + " character code: " + event.charCode + ")");
			if (event.keyCode == 65){ //a
				//step 1
				setChildIndex( organism_vis, numChildren - 1 );
				organism_vis.visible = true;
				guess_table.visible = false;
				rank_table.visible = false;
				rationale_table.visible = false;
				
			} else if (event.keyCode == 83){//s
				//step 2
				setChildIndex( guess_table, numChildren - 1 );
				organism_vis.visible = false;
				guess_table.visible = true;
				rank_table.visible = false;
				rationale_table.visible = false;
				
			} else if (event.keyCode == 68){//d
				//step 4 rank
				setChildIndex( rank_table, numChildren - 1 );
				organism_vis.visible = false;
				guess_table.visible = false;
				rank_table.visible = true;
				rationale_table.visible = false;
				
			} else if ( event.keyCode == 70){//f
				//step 4 rationale
				setChildIndex( rationale_table, numChildren - 1 );
				organism_vis.visible = false;
				guess_table.visible = false;
				rank_table.visible = false;
				rationale_table.visible = true;
			}	
		}
		
		//{"eventType":"organism_present","payload":{"group_code":"A1","author":"joe","location":"rainforest_a","first_organism":{"organism":"monkey","present":"true"},"second_organism":{"organism":"wasp","present":"false"}}}	
		private function organism_present( eventData ):void 
		{
			event_debug.appendText("/n" + eventData.author + " identified " + eventData.second_organism.organism + "'s prescence as " + eventData.second_organism.present);
			
			if (eventData.first_organism.present == true){
				//add new name	
				organism_vis.addTag(eventData.first_organism.organism , eventData.author, eventData.location);
			}
			
			if (eventData.second_organism.present == true){
				//add new name
				organism_vis.addTag(eventData.second_organism.organism , eventData.author, eventData.location);
			}
		}
		//{"eventType":"rainforest_guess_submitted", "payload":{"group_code":"A1", "author":"joe", "location":"rainforest_a", "your_rainforest":"true", "explanation":"foo"}}
		private function rainforest_guess_submitted( eventData ):void
		{
			event_debug.text = eventData.group_code + " group submitted a guess entry for " + eventData.location + ": " + eventData.your_rainforest;  
			guess_table.addEntry( eventData.group_code, eventData.location, eventData.your_rainforest, eventData.explanation );
		}
		//{"eventType":"rankings_submitted", "payload":{"group_code":"A1", "author":"joe", "ranks":{"rainforest_a":"2", "rainforest_b":"4", "rainforest_a":"2", "rainforest_c":"1", "rainforest_d":"3"}}}
		private function rankings_submitted( eventData ):void
		{
			event_debug.text = eventData.group_code + " group submitted a ranking entry: A = " + eventData.ranks.rainforest_a;  
			rank_table.addEntry( eventData.group_code, eventData.author, eventData.ranks.rainforest_a, eventData.ranks.rainforest_b, eventData.ranks.rainforest_c, eventData.ranks.rainforest_d);
		}
		//{"eventType":"rationale_submitted", "payload":{"group_code":"A1", "author":"jane", "question":"strategy", "answer":"foo"}}
		private function rationale_submitted( eventData ):void
		{
			event_debug.text = eventData.author + " from group " + eventData.group_code + " submitted a rationale entry for " + eventData.question;  
			rationale_table.addEntry( eventData.group_code, eventData.author, eventData.question, eventData.answer );
		}
		private function handleSev(eventType, eventData):void 
		{
			trace(eventType);
			trace(eventData);
			event_debug.text = "handleSev";
			
			switch(eventType) {
				// add handlers for events here (one for each type of event)
				case "organism_present":
					organism_present(eventData); 
					break;
				case "rainforest_guess_submitted":
					rainforest_guess_submitted(eventData); 
					break;
				case "rankings_submitted":
					rankings_submitted(eventData); 
					break;
				case "rationale_submitted":
					rationale_submitted(eventData); 
					break;
				default:
					trace("Unrecognized event received: "+eventType);
			}
		}
		//EXAMPLE 1: CAN BE ERASED
		private function student_submitted_data(eventData) {
			// eventData is an object with arbitrary properties (Armin/Colin will define these)
			event_debug.text = "Got 'student_submited_data'; foo is " + eventData.foo;
		}
		//EXAMPLE 2: CAN BE ERASED
		private function some_other_event(eventData) {
			// eventData is an object with arbitrary properties (Armin/Colin will define these)
			event_debug.text = "Got 'some_other_event'; blah_blah is " + eventData.blah_blah + " and poop is " + eventData.poop;
		}
	}
}




