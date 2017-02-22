<?php
/**
 * 功能 客户列表查询
 * @author siht
 * 时间：2016-10-03
 */
class CustListAction extends BaseAction 
{
	public $user_id;		//用户id
	public $current_page;   //当前页
	public $page_size;   //每页大小

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->user_id = I('user_id'); //用户id
		$this->current_page = I('current_page'); 
		$this->page_size = I('page_size'); 
	}
		
	public function run() {		
		$rs = $this->check(); 
		if(!($rs===true)){
			$this->returnError($rs['resp_desc'],'9002');
		}

		//查推荐码
		$where = "id = ".$this->user_id;	
		$user_info = M('Tuser')->where($where)->find();
		if(!$user_info)
		{
			$this->returnError("无效的用户id", '9001');
		}

		//查客户列表
		$where = "remark_code = ".$user_info['remark_code'];
		$user_list = M('Tuser')->where($where)->select();
		if(!empty($user_list)){	
			for($i=0; $i < count($user_list); ++$i)
			{
				//汇总订单数
				$where_detail = "user_id = ".$user_list[$i]['user_list'];
				$sum_count = M('TuserDayStat')->where($where_detail)->sum('occur_count');
				$month_count = 0;
				if(!$sum_count)
				{
					$sum_count = 0;
				}
				else
				{
					//汇总当月订单数
					$where_detail = "user_id = ".$user_list[$i]['user_list']." and date >= ".date('Ym01')." and date <= ".date('Ym31');
					$month_count = M('TuserDayStat')->where($where_detail)->sum('occur_count');
					if(!$month_count)
					{
						$month_count = 0;
					}
				}
				$user_list[$i]['month_count'] = $month_count;
				$user_list[$i]['sum_count'] = $sum_count;
			}
			$this->returnSuccess($resp_desc, array('cust_list' => $user_list));
		}
		else
		{
			$this->returnError("无客户", '0000');
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