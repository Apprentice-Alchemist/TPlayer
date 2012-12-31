package ;

import kha.Button;
import kha.Game;
import kha.LoadingScreen;
import kha.Painter;
import kha.System;
import kha.Tilemap;
import kha.Scene;
import kha.Loader;
import kha.Music;

class Mapstatus {
	static public var NORMALSTATUS = 0;
	static public var HOEHLE = 1;			//Hintergrund ist schwarz
	static public var WASSERFALL = 2;		//Wasser spritzt von Turri
	static public var WASSERBECKEN = 3;	//Wassertexturen
	static public var UNTERWASSER = 4;	//Wassertexturen und tauchen
	static public var WIND_R = 5;			//Wind von rechts
	static public var WIND_L = 6;			//Wind von links
	static public var STURM_R = 7;		//starker Wind von rechts
	static public var STURM_L = 8;		//starker Wind von links
	static public var FLUSS_R = 9;		//Fluss von rechts
	static public var FLUSS_L = 10;		//Fluss von links
	static public var EXIT_RECHTS = 11;	//Levelausgang rechts
	static public var EXIT_LINKS = 12;		//Levelausgang links
	static public var EXIT_OBEN = 13;		//Levelausgang oben
	static public var EXIT_UNTEN = 14;		//Levelausgang unten
	static public var FBAND_R = 15;		//Fliessband von rechts
	static public var FBAND_L = 16;			//Fliessband von links
}

class TPlayer extends Game {
	public function new() {
		super("TPlayer", 800, 600, false);
	}

	public override function init(): Void {
		System.setScreen(new LoadingScreen(800, 600));
		Loader.the().loadRoom("level1", levelLoaded);
	}
	
	function levelLoaded(): Void {
		var blob = Loader.getInstance().getBlob("Level2.lv6");
		
		var world = blob.readUInt16LE();
		var xstart = blob.readUInt16LE();
		var ystart = blob.readUInt16LE();
		var width = blob.readUInt16LE();
		var height = blob.readUInt16LE();
		
		var backmap = new Array<Array<Int>>();
		var backstate = new Array<Array<Int>>();
		var map = new Array<Array<Int>>();
		var state = new Array<Array<Int>>();
		var sprites = new Array<Array<Int>>();
		var hitpoints = new Array<Array<Int>>();
		
		for (x in 0...width) {
			backmap.push(new Array<Int>());
			backstate.push(new Array<Int>());
			map.push(new Array<Int>());
			state.push(new Array<Int>());
			sprites.push(new Array<Int>());
			hitpoints.push(new Array<Int>());
			for (y in 0...height) {
				backmap[x].push(0);
				backstate[x].push(0);
				map[x].push(0);
				state[x].push(0);
				sprites[x].push(0);
				hitpoints[x].push(0);
			}
		}
		
		for (y in 0...height) for (x in 0...width) backmap[x][y] = blob.readUInt16LE();
		for (y in 0...height) for (x in 0...width) backstate[x][y] = blob.readUInt16LE();
		for (y in 0...height) for (x in 0...width) map[x][y] = blob.readUInt16LE();
		for (y in 0...height) for (x in 0...width) state[x][y] = blob.readUInt16LE();
		for (y in 0...height) for (x in 0...width) sprites[x][y] = blob.readUInt16LE();
		for (y in 0...height) for (x in 0...width) hitpoints[x][y] = blob.readUInt16LE();
		
		var world = Loader.getInstance().getBlob("World9.bl6");
		var num = world.readUInt16LE();
		var types = new Array<Int>();
		for (i in 0...num) types.push(world.readUInt16LE());
		var data1 = new Array<Int>();
		for (i in 0...num) data1.push(world.readUInt16LE());
		var data2 = new Array<Int>();
		for (i in 0...num) data2.push(world.readUInt16LE());
		var data3 = new Array<Int>();
		for (i in 0...num) data3.push(world.readUInt16LE());
		
		Tile.tiles = new Array<kha.Tile>();
		for (i in 0...num) {
			Tile.tiles.push(new Tile(Loader.getInstance().getImage("World9.png"), i, types[i], data1[i], data2[i], data3[i]));
		}
		var backtilemap : Tilemap = new Tilemap("World9.png", 32, 32, backmap, Tile.tiles);
		var tilemap : Tilemap = new Tilemap("World9.png", 32, 32, map, Tile.tiles);
		Scene.getInstance().setColissionMap(tilemap);
		Scene.getInstance().camx = xstart * 32;
		Scene.getInstance().camy = ystart * 32;
		Scene.getInstance().addBackgroundTilemap(backtilemap, 0.5);
		Scene.getInstance().addBackgroundTilemap(tilemap, 1);
		var music : Music = Loader.getInstance().getMusic("L_cave");
	//	music.start();
		var turrican = new Turrican();
		turrican.x = xstart * 32;
		turrican.y = ystart * 32;
		Scene.getInstance().addHero(turrican);
		
		Explosion.init();
		shots.BallShot.init();
		shots.SmallBallShot.init();
		enemy.Walker.init();
		
		for (y in 0...height) {
			for (x in 0...width) {
				switch (sprites[x][y]) {
				case 1: Scene.getInstance().addEnemy(new enemy.Walker(x * 32, y * 32));
				case 2: Scene.getInstance().addEnemy(new enemy.Fly(x * 32, y * 32));
				case 3:
					//layer->add(new Bomb(x * 32, y * 32));
				case 4:
					//Mine North
				case 5:
					//Mine North-West
				case 6:
					//Mine South-West
					//layer->add(new Mine(x * 32, y * 32));
				case 7:
					//layer->add(new Dragon(x * 32, y * 32));
				case 8:
					//layer->add(new Nest(x * 32, y * 32));
				case 9:
					//layer->add(new Zapfen(x * 32, y * 32));
				case 10:
					//layer->add(new ExtraFly(x * 32, y * 32));
				case 11:
					//layer->add(new DrehkolbenUnten(x * 32, y * 32));
					break;
				case 12:
					//layer->add(new DrehkolbenOben(x * 32, y * 32));
				case 13:
					//layer->add(new LaserWummeUnten(x * 32, y * 32));
				case 14:
					//layer->add(new LaserWummeOben(x * 32, y * 32));
				case 15:
					//layer->add(new Fledermaus(x * 32, y * 32));
				case 16:
					//layer->add(new Spinne(x * 32, y * 32));
				case 17:
					//layer->add(new Laeufer(x * 32, y * 32));
				case 18:
					//layer->add(new SternGross(x * 32, y * 32));
				case 19:
					//layer->add(new SternKlein(x * 32, y * 32));
				case 20:
					//layer->add(new FischBunt(x * 32, y * 32));
				case 21:
					//layer->add(new FischGross(x * 32, y * 32));
				case 22:
					//layer->add(new QualleBraun(x * 32, y * 32));
				case 23:
					//layer->add(new QualleGrau(x * 32, y * 32));
				case 24:
					//layer->add(new SchwimmWalker(x * 32, y * 32));
				case 25:
					//layer->add(new WasserDreher(x * 32, y * 32));
				case 26:
					//layer->add(new SteinSchlag(x * 32, y * 32));
				case 27:
					//layer->add(new RaketenWerfer(x * 32, y * 32));
				case 28:
					//layer->add(new KanoneLinks(x * 32, y * 32));
				case 29:
					//layer->add(new KanoneRechts(x * 32, y * 32));
				case 30:
					//layer->add(new Bazooka(x * 32, y * 32));
				case 31:
					//layer->add(new Stachelkugel(x * 32, y * 32));
				case 32:
					//layer->add(new FischNormal(x * 32, y * 32));
				case 33:
					//layer->add(new FluegelWalker(x * 32, y * 32));
				case 34:
					//layer->add(new Schleimmonster(x * 32, y * 32));
				case 35:
					//layer->add(new AlienStehend(x * 32, y * 32));
				case 36:
					//layer->add(new AlienLauf(x * 32, y * 32));
				case 37:
					//layer->add(new ZungeLinks(x * 32, y * 32));
				case 38:
					//layer->add(new ZungeRechts(x * 32, y * 32));
				case 39:
					//layer->add(new AlienKapsel(x * 32, y * 32));
				case 40:
					//layer->add(new AlienHuepf(x * 32, y * 32));
				case 41:
					//layer->add(new Tropfen(x * 32, y * 32));
				case 42:
					//nach links
					//layer->add(new Made(x * 32, y * 32));
				case 43:
					//rechts
					//layer->add(new Made(x * 32, y * 32));
				case 44:
					//layer->add(new FeuerWalkerLinks(x * 32, y * 32));
				case 45:
					//layer->add(new FeuerWalkerRechts(x * 32, y * 32));
				case 46:
					//layer->add(new FlugWalker(x * 32, y * 32));
				case 47:
					//layer->add(new SchleuderMine(x * 32, y * 32));
				case 48:
					//layer->add(new Presse(x * 32, y * 32));
				case 49:
					//layer->add(new Zahnrad(x * 32, y * 32));
				case 50:
					//layer->add(new Flammen(x * 32, y * 32));
				case 51:
					//layer->add(new FirstBoss(x * 32, y * 32));
				case 52:
					//layer->add(new BossKopf(x * 32, y * 32));
				case 53:
					//layer->add(new BossRiesenraumschiff(x * 32, y * 32));
				case 54:
					//layer->add(new BossRiesenFisch(x * 32, y * 32));
				case 55:
					//layer->add(new BossFaust(x * 32, y * 32));
				case 56:
					//layer->add(new BossAuge(x * 32, y * 32));
				case 57:
					//layer->add(new BossRiesenWalker(x * 32, y * 32));
				case 58:
					//layer->add(new BossDrache(x * 32, y * 32));
				case 59:
					//layer->add(new BossAlienSchiff(x * 32, y * 32));
				case 60:
					//layer->add(new Diamond(x * 32, y * 32));
				case 61:
					//layer->add(new Power(x * 32, y * 32));
				case 62:
					//layer->add(new Shield(x * 32, y * 32));
				case 63:
					//layer->add(new SpreadshotBonus(x * 32, y * 32));
				case 64:
					//layer->add(new LaserBonus(x * 32, y * 32));
				case 65:
					//layer->add(new Bounce(x * 32, y * 32));
				case 66:
					//layer->add(new Blitz(x * 32, y * 32));
				case 67:
					//layer->add(new Line(x * 32, y * 32));
				case 68:
					//layer->add(new Grenade(x * 32, y * 32));
				case 69:
					//layer->add(new OneUp(x * 32, y * 32));
				case 70:
					//layer->add(new Jetpack(x * 32, y * 32));
				case 71:
					//bonusblock1_b3x44x34
				case 72:
					//bonusblock2_b3x44x34
				case 73:
					//bonusblock3_b3x96x72
				case 74:
					//bonusblock4_b3x60x32
					//layer->add(new BonusBlock(x * 32, y * 32));
				case 75:
					//blue blocker
				case 76:
					//Platform up down
				case 77:
					//Platform big up down
				case 78:
					//Platform right left
					//layer->add(new Platform(x * 32, y * 32));
				case 79:
					//red blocker
				case 80:
					//layer->add(new Blatt(x * 32, y * 32));
				case 81:
					//layer->add(new Rauch(x * 32, y * 32));
				case 82:
					//layer->add(new WasserSpritzer(x * 32, y * 32));
				case 83:
					//layer->add(new Luftblase(x * 32, y * 32));
				case 84:
					//layer->add(new Flammenrauch(x * 32, y * 32));
				case 85:
					//layer->add(new Truemmer(x * 32, y * 32));
				case 86:
					//layer->add(new BrokenWalker(x * 32, y * 32));
				case 87:
					//layer->add(new SchraubWalker(x * 32, y * 32));
				case 88:
					//layer->add(new SchluesselWalker(x * 32, y * 32));
				case 89:
					//layer->add(new KranWalker(x * 32, y * 32));
				case 90:
					//layer->add(new Schraube(x * 32, y * 32));
				}
			}
		}
		System.setScreen(this);
	}

	override public function update() : Void {
		//++Scene.getInstance().camx;
		//++Scene.getInstance().camy;
		for (tile in Tile.tiles) cast(tile, Tile).update();
		Scene.getInstance().camy = Std.int(Turrican.getInstance().y) + Std.int(Turrican.getInstance().height / 2);
		super.update();
		Scene.getInstance().camx = Std.int(Turrican.getInstance().x) + Std.int(Turrican.getInstance().width / 2);
	}
	
	override public function render(painter : Painter) : Void {
		painter.translate(0, 0);
		painter.drawImage(Loader.getInstance().getImage("bg2.png"), 0, 0);
		super.render(painter);
	}
	
	override public function buttonDown(button : Button) : Void {
		switch (button) {
		case UP, BUTTON_1:
			Turrican.getInstance().setUp();
		case LEFT:
			Turrican.getInstance().left = true;
		case RIGHT:
			Turrican.getInstance().right = true;
		case BUTTON_2:
			Turrican.getInstance().shot();
		default:
		}
	}
	
	override public function buttonUp(button : Button) : Void {
		switch (button) {
		case UP, BUTTON_1:
			Turrican.getInstance().up = false;
		case LEFT:
			Turrican.getInstance().left = false;
		case RIGHT:
			Turrican.getInstance().right = false;
		default:
		}	
	}
}