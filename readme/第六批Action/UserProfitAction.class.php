<?php
/**
 * 功能：推荐人收益
 * @author siht
 * 时间：2016-10-03
 */

class UserProfitAction extends BaseAction
{
	//接口参数
	public $user_id;  //用户id
	public $begin_date;//开始日期 （生成透视图的区间）
	public $end_date;//结束日期（生成透视图的区间）
	
	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->user_id = I('user_id');
		$this->begin_date = I('begin_date');
		$this->end_date = I('end_date');
				
	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}
		
		//1.查累计收益
		$where = "user_id = ".$this->user_id;
		$sum_count = M('TuserDayStat')->where($where)->sum('occur_count');
		$month_count = 0;
		if(!$sum_count)
		{
			$sum_count = 0;
		}
		else
		{
			$where .= " and date >= ".date('Ym01')." and date <= ".date('Ym31');
			$month_count = M('TuserDayStat')->where($where)->sum('occur_count');
			if(!$month_count)
			{
				$month_count = 0;
			}
		}
		$where = "user_id = ".$this->user_id." and date >= ".$this->begin_date." and date <= ".$this->end_date;
		$profit_list = M('TuserDayStat')->where($where)->select();

		$resp_data = array();
		$resp_data['sum_count'] = $sum_count;
		$resp_data['month_count'] = $month_count;
		$resp_data['profit_list'] = $profit_list;

		$this->returnSuccess("查询收益成功",$resp_data);
	}

	

	private function check(){
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户id不能为空！');
			return false;
		}
		if($this->begin_date == '')
		{
			return array('resp_desc'=>'开始日期不能为空！');
			return false;
		}
		if($this->end_date == '')
		{
			return array('resp_desc'=>'截止日期不能为空！');
			return false;
		}
		return true;
	}
}
?>