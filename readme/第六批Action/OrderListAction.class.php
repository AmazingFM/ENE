<?php
/**
 * 功能 订单列表查询
 * @author siht
 * 时间：2016-09-10
 */
class OrderListAction extends BaseAction 
{
	public $user_id;		//用户id
	public $begin_time;		//查询开始时间
	public $end_time;		//查询结束时间
	public $status;			//订单状态

	public $current_page;   //当前页
	public $page_size;   //每页大小


	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->user_id = I('user_id');
		$this->begin_time = I('begin_time'); 
		$this->end_time = I('end_time'); 
		$this->status = I('status'); 

		$this->current_page = I('current_page'); 
		$this->page_size = I('page_size'); 
	}

	public function run() {		
		$rs = $this->check(); 
		if(!($rs===true)){
			$this->returnError($rs['resp_desc'],'9002');
		}
		$todayTime = date('YmdHis');

		$where = "user_id = ".$this->user_id;

		if(isset($this->begin_time) && $this->begin_time !=''){
			$where .= " and add_time >= ".$this->begin_time; 
		}
		if(isset($this->end_time) && $this->end_time !=''){
			$where .= " and add_time <= ".$this->end_time;
		}
		if(isset($this->status) && $this->status !=''){
			$where .= " and status = ".$this->status; 
		}
	
		$start = ($this->current_page -1) * $this->page_size;
		$order_list = M('Torder')->where($where)->limit("{$start},{$this->page_size}")->select();
		
		
		if(!empty($order_list)){
			$resp_desc = "获取订单列表成功";

			//查订单商品明细
			for($i=0; $i < count($order_list); ++$i)
			{
				$where_detail = "order_id = ".$order_list[$i]['order_id'];
				$order_detail = M('TorderDetail')->where($where_detail)->select();
				$order_list[$i]['order_detail'] = $order_detail;
			}
						
			$all_count = M('Torder')->where($where)->count();
			$page_info = array();
			$page_info['page_size'] = $this->page_size;
			$page_info['current_page'] = $this->current_page;
			$page_info['total_num'] = $all_count;	
			$page_info['total_page'] = ceil($all_count/$this->page_size);
								
			$this->returnSuccess($resp_desc, array('order_list' => $order_list, 'page_nav' => $page_info));
		}
		else
		{
			$this->returnError("无订单", '0000');
		}
	}
	
	private function check(){	
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户id不能为空！');
			return false;
		}
		if($this->current_page == '')
		{
			return array('resp_desc'=>'当前页不能为空！');
			return false;
		}
		if($this->page_size == '')
		{
			return array('resp_desc'=>'单页大小不能为空！');
			return false;
		}
		if($this->page_size <= 0)
		{
			return array('resp_desc'=>'单页大小必须大于0！');
			return false;
		}
		return true;
	}	
}
?>
