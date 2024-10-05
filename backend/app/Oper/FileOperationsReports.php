<?php

namespace App\Oper;

use App\Models\Report;
use Illuminate\Support\Facades\Auth;

class FileOperationsReports
{
    function saveCheckInReportUser($id)
    {
        Report::query()->create([
            'operation_type' => 1,
            'user_id' => Auth::id(),
            'admin_id',
            'file_id' => $id
        ]);
    }

    function saveCheckInReportAdmin($id)
    {
        Report::query()->create([
            'operation_type' => 1,
            'user_id',
            'admin_id' => Auth::id(),
            'file_id' => $id
        ]);
    }

    function saveCheckOutReportUser($id)
    {
        Report::query()->create([
            'operation_type' => 2,
            'user_id' => Auth::id(),
            'admin_id',
            'file_id' => $id
        ]);
    }

    function saveCheckOutReportAdmin($id)
    {
        Report::query()->create([
            'operation_type' => 2,
            'user_id',
            'admin_id' => Auth::id(),
            'file_id' => $id
        ]);
    }

    function saveEditFileReportUser($id)
    {
        Report::query()->create([
            'operation_type' => 4,
            'user_id' => Auth::id(),
            'admin_id',
            'file_id' => $id
        ]);
    }

    function saveEditFileReportAdmin($id)
    {
        Report::query()->create([
            'operation_type' => 4,
            'user_id',
            'admin_id' => Auth::id(),
            'file_id' => $id
        ]);
    }
}
