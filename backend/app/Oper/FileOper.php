<?php

namespace App\Oper;

use App\Models\Admin;
use App\Models\Report;
use App\Models\User;

class FileOper
{
    public function saveFile($request, $file)
    {
        $file->addMedia($request->file)->toMediaCollection();
        $file->save();
    }

    public function saveFileEdit($request, $file)
    {
        $file->clearMediaCollection();
        $file->addMedia($request->file)->toMediaCollection();
        $file->save();
    }

    public function getBlockingUser($id)
    {
        $report = Report::query()->where('file_id', $id)
            ->where('operation_type', 1)
            ->orderByDesc('id')
            ->first();
        if (isset($report->user_id))
            return User::query()->find($report->user_id);
        else
            return Admin::query()->find($report->admin_id);
    }

}
