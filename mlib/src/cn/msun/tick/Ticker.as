package cn.msun.tick {
    import cn.msun.event.Event;
    import cn.msun.event.EventSender;
    
    /**
     * 管理一组ITick，可变速(FPS)
     *
     * @author Msun
     */
    public class Ticker implements ITick {
        
        private var ticks:Vector.<ITick>;
        private var currentFrame:uint;
        private var currentTime:uint;
        private var _fps:uint;
        
        public function Ticker() {
            currentFrame = 0;
            currentTime = 0;
            ticks = new <ITick>[];
        }
        
        //todo
        public function get fps():uint {
            return _fps;
        }
        
        public function set fps(value:uint):void {
        
        }
        
        public function add(tick:ITick):void {
            if(tick && ticks.indexOf(tick) < 0) {
                ticks.push(tick);
                
                var es:EventSender = tick as EventSender;
                
                if(es) {
                    es.addListener(Event.REMOVE_FROM_TICKER, removeHandler);
                }
            }
        }
        
        public function remove(tick:ITick):void {
            if(tick) {
                var es:EventSender = tick as EventSender;
                
                if(es) {
                    es.removeListener(Event.REMOVE_FROM_TICKER, removeHandler);
                }
                
                var index:int = ticks.indexOf(tick);
                
                if(index >= 0) {
                    ticks[index] = null;
                }
            }
        }
        
        public function clear():void {
            for(var i:int = ticks.length; i >= 0; --i) {
                var es:EventSender = ticks.pop() as EventSender;
                
                if(es) {
                    es.removeListener(Event.REMOVE_FROM_TICKER, removeHandler);
                }
            }
        }
        
        public function tick(tickTime:uint, totalTime:uint, frame:uint):void {
            var num:uint = ticks.length;
            var index:uint = 0;
            var i:uint = 0;
            var tick:ITick;
            
            currentTime += tickTime;
            ++currentFrame;
			
			//todo 变速如何实现？？？
            
            if(num == 0)
                return;
            
            for(i = 0; i < num; ++i) {
                tick = ticks[i];
                
                if(tick) {
                    tick.tick(tickTime, currentTime, currentFrame);
                    
                    //remove时只是将数组对应位置设为null，现在要将null移到尾部，在下边将删除
                    if(index != i) {
                        ticks[index] = tick;
                        ticks[i] = null;
                    }
                    
                    ++index;
                }
            }
            
            if(index != i) {
                //有空洞,删除之
                num = ticks.length;
                
                //ticks可能变长了
                while(i < num) {
                    ticks[index++] = ticks[i++];
                }
                
                ticks.length = index;
            }
        }
        
        private function removeHandler(event:Event):void {
            remove(event.target as ITick);
        }
    }
}
