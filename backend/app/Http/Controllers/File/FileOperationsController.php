<?php

namespace App\Http\Controllers\File;

use App\Http\Controllers\Controller;
use App\Http\Requests\BulkCheckInRequest;
use App\Http\Requests\CheckInRequest;
use App\Http\Requests\EditFileRequest;
use App\Models\File;
use App\Oper\FileOper;
use App\Oper\FileOperationsReports;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use JetBrains\PhpStorm\Pure;

class FileOperationsController extends Controller
{
    private FileOperationsReports $report;
    private FileOper $oper;


    /** @noinspection PhpPureAttributeCanBeAddedInspection */
    public function __construct()
    {
        $this->report = new FileOperationsReports();
        $this->oper = new FileOper();

    }

    public function checkInUser(CheckInRequest $request): JsonResponse
    {
        $file = File::query()->where('id', $request->file_id)
            ->where('status', 1)
            ->where('version', $request->version)
            ->update(['status' => 0]);
        if (!$file)
            return response()->json([
                'status' => false,
                'message' => 'Can\'t check-in the file'
            ], 400);
        $this->report->saveCheckInReportUser($request->file_id);
        return response()->json([
            'status' => true,
            'message' => 'check-in succeeded'
        ]);
    }

    //transaction
    public function checkOutUser($id): JsonResponse
    {
        $file = File::query()->find($id);
        DB::beginTransaction();
        $version = $file->increment('version');
        $status = $file->update(['status' => 1]);
        $this->report->saveCheckOutReportUser($id);
        if (!$version || !$status) {
            DB::rollBack();
            return response()->json([
                'status' => false,
                'message' => 'check-out failed'
            ], 400);
        } else {
            DB::commit();
            return response()->json([
                'status' => true,
                'message' => 'check-out succeeded'
            ]);
        }
    }

    public function editFileUser(EditFileRequest $request): JsonResponse
    {
        $file = File::query()->find($request->file_id);
        $this->oper->saveFileEdit($request, $file);
        $this->report->saveEditFileReportUser($file->id);
        return response()->json([
            'status' => true,
            'data' => $file
        ]);
    }

    public function bulkCheckIn(BulkCheckInRequest $request)
    {
        DB::beginTransaction();
        $files=$request->files_id;
        foreach ($files as $file){
            $result = File::query()->where('id', $file['file_id'])
                ->where('status', 1)
                ->where('version', $file['version'])
                ->update(['status' => 0]);
            $this->report->saveCheckInReportUser($file['file_id']);
            if (!$result) {
                DB::rollBack();
                return response()->json([
                    'status' => false,
                    'message' => 'Can\'t check-in the file'
                ], 400);
            }
        }
        DB::commit();
        return response()->json([
            'status' => true,
            'message' => 'check-in succeeded',
            'files'=>$files
        ]);
    }

}

/*
 * public function checkInAdmin($id): JsonResponse
    {
        $file = File::query()->find($id);
        if ($file->status == 0) {
            return response()->json([
                'status' => false,
                'message' => 'Can\'t check-in the file'
            ]);
        }
        $file->update(['status' => 0]);
        $this->report->saveCheckInReportAdmin($id);
        return response()->json([
            'status' => true,
            'message' => 'check-in succeeded'
        ]);
    }
 */

/*
 * public function checkOutAdmin($id): JsonResponse
    {
        $file = File::query()->find($id);
        $file->update(['status' => 1]);
        $this->report->saveCheckOutReportAdmin($id);
        return response()->json([
            'status' => true,
            'message' => 'check-out succeeded'
        ]);
    }
 */

/*
 * public function editFileAdmin(EditFileRequest $request): JsonResponse
    {
        $file = File::query()->find($request->file_id);
        $this->oper->saveFileEdit($request, $file);
        $this->report->saveEditFileReportAdmin($file->id);
        return response()->json([
            'status' => true,
            'data' => $file
        ]);
    }
 */
