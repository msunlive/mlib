package cn.msun.event {
    
    /**
     * @author Msun
     */
    public class IBubble extends EventSender {
        private var _parent:IBubble;
        
        public function get parent():IBubble {
            return _parent;
        }
    }
}
